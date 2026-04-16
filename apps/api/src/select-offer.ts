import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { fail } from './response';
import { ensureOffersSchema } from './offers';
import { assertMasterCanAcceptCashJob } from './payments/payment-rules';
import { ensurePaymentsSchema } from './payments';

async function ensureMasterBillingSchema(env: any) {
  const columns = await env.DB.prepare('PRAGMA table_info(master_profiles)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['has_billing_method', 'ALTER TABLE master_profiles ADD COLUMN has_billing_method INTEGER NOT NULL DEFAULT 0'],
    ['billing_status', "ALTER TABLE master_profiles ADD COLUMN billing_status TEXT NOT NULL DEFAULT 'missing'"],
    ['cash_jobs_enabled', 'ALTER TABLE master_profiles ADD COLUMN cash_jobs_enabled INTEGER NOT NULL DEFAULT 0'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }
}

export async function selectOffer(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureOffersSchema(env);
  await ensureMasterBillingSchema(env);
  await ensurePaymentsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  let body: any;
  try {
    body = await request.json();
  } catch {
    return fail('Invalid JSON body', 400);
  }

  if (!body.offer_id) {
    return fail('offer_id is required', 400);
  }

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return fail('Job not found', 404);
  }

  if (job.client_user_id !== auth.userId) {
    return fail('Only job client can select master', 403);
  }

  if (job.status !== JOB_STATUS.open) {
    return fail('Master can be selected only for open job', 400);
  }

  try {
    assertTransition(job.status, JOB_STATUS.master_selected);
  } catch (error: any) {
    return fail(error?.message ?? 'Invalid status transition', 400);
  }

  const offer = await env.DB.prepare(
    'SELECT * FROM offers WHERE id = ?1 AND job_id = ?2'
  )
    .bind(body.offer_id, jobId)
    .first();

  if (!offer) {
    return fail('Offer not found for this job', 404);
  }

  if (job.payment_method === 'card') {
    const deposit = await env.DB.prepare(
      `SELECT * FROM payments
       WHERE job_id = ?1
         AND type = 'deposit'
         AND status = 'paid'
       ORDER BY created_at DESC
       LIMIT 1`
    )
      .bind(jobId)
      .first();

    if (!deposit) {
      return fail('Deposit payment required before selecting master', 400);
    }
  }

  let masterPaymentMethod: any = null;

  if (job.payment_method === 'cash') {
    const masterProfile = await env.DB.prepare(
      `SELECT
         has_billing_method,
         billing_status,
         cash_jobs_enabled
       FROM master_profiles
       WHERE user_id = ?1
       LIMIT 1`
    )
      .bind(offer.master_user_id)
      .first();

    try {
      assertMasterCanAcceptCashJob({
        hasBillingMethod: !!masterProfile?.has_billing_method,
        billingStatus: masterProfile?.billing_status ?? 'missing',
        cashJobsEnabled: !!masterProfile?.cash_jobs_enabled,
      });
    } catch {
      return fail(
        'Master cannot accept cash job without active billing method',
        400
      );
    }

    masterPaymentMethod = await env.DB.prepare(
      `SELECT id, provider, provider_payment_method_id
       FROM payment_methods
       WHERE user_id = ?1
         AND status = 'active'
       ORDER BY is_default DESC, created_at ASC
       LIMIT 1`
    )
      .bind(offer.master_user_id)
      .first();

    if (!masterPaymentMethod) {
      return fail('Active master payment method not found', 400);
    }

    const existingCashDeposit = await env.DB.prepare(
      `SELECT id
       FROM payments
       WHERE job_id = ?1
         AND type = 'deposit'
         AND payer_role = 'master'
       LIMIT 1`
    )
      .bind(jobId)
      .first();

    if (!existingCashDeposit) {
      const paymentId = crypto.randomUUID();

      await env.DB.prepare(
        `INSERT INTO payments (
          id,
          job_id,
          client_user_id,
          payer_user_id,
          payment_method_id,
          payer_role,
          source,
          provider,
          provider_ref,
          amount,
          currency,
          type,
          status,
          created_at
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14)`
      )
        .bind(
          paymentId,
          jobId,
          job.client_user_id,
          offer.master_user_id,
          masterPaymentMethod.id,
          'master',
          'master_card',
          masterPaymentMethod.provider ?? 'mock',
          `mock_master_charge_${paymentId}`,
          job.deposit_amount,
          job.currency || 'THB',
          'deposit',
          'paid',
          new Date().toISOString()
        )
        .run();
    }
  }

  const now = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE jobs
     SET selected_offer_id = ?1,
         selected_master_name = ?2,
         selected_master_user_id = ?3,
         selected_offer_price = ?4,
         status = ?5,
         updated_at = ?6
     WHERE id = ?7`
  )
    .bind(
      offer.id,
      offer.master_name,
      offer.master_user_id,
      offer.price,
      JOB_STATUS.master_selected,
      now,
      jobId
    )
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      selected_offer_id: offer.id,
      selected_master_name: offer.master_name,
      selected_master_user_id: offer.master_user_id,
      selected_offer_price: offer.price,
      status: JOB_STATUS.master_selected,
      updated_at: now,
    },
  });
}
