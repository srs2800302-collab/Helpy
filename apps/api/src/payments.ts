import { JOB_STATUS, assertTransition } from './job-status';
import { ensureJobsSchema } from './jobs';
import { requireAuth } from './auth-context';
import { ok, fail } from './response';

function paymentData(payment: any, jobId: string, jobStatus: string) {
  return {
    id: payment.id,
    job_id: jobId,
    payer_user_id: payment.payer_user_id ?? payment.client_user_id ?? null,
    payment_method_id: payment.payment_method_id ?? null,
    payer_role: payment.payer_role ?? 'client',
    source: payment.source ?? 'client_card',
    provider: payment.provider ?? 'mock',
    provider_ref: payment.provider_ref ?? null,
    amount: payment.amount,
    currency: payment.currency,
    status: payment.status ?? 'paid',
    job_status: jobStatus,
    ...(payment.created_at ? { created_at: payment.created_at } : {}),
  };
}

async function getJob(jobId: string, env: any) {
  return env.DB.prepare('SELECT * FROM jobs WHERE id = ?1').bind(jobId).first();
}

async function getPaymentByType(jobId: string, type: string, env: any) {
  return env.DB.prepare(
    `SELECT * FROM payments
     WHERE job_id = ?1
       AND type = ?2
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId, type)
    .first();
}

async function getPaidDeposit(jobId: string, env: any) {
  return env.DB.prepare(
    `SELECT * FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
       AND status = 'paid'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();
}

export async function ensurePaymentsSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      client_user_id TEXT NOT NULL,
      payer_user_id TEXT,
      payment_method_id TEXT,
      payer_role TEXT NOT NULL DEFAULT 'client',
      source TEXT NOT NULL DEFAULT 'client_card',
      provider TEXT NOT NULL DEFAULT 'mock',
      provider_ref TEXT,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      type TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`
  ).run();

  const columns = await env.DB.prepare('PRAGMA table_info(payments)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['job_id', 'ALTER TABLE payments ADD COLUMN job_id TEXT'],
    ['client_user_id', 'ALTER TABLE payments ADD COLUMN client_user_id TEXT'],
    ['payer_user_id', 'ALTER TABLE payments ADD COLUMN payer_user_id TEXT'],
    ['payment_method_id', 'ALTER TABLE payments ADD COLUMN payment_method_id TEXT'],
    ['payer_role', "ALTER TABLE payments ADD COLUMN payer_role TEXT NOT NULL DEFAULT 'client'"],
    ['source', "ALTER TABLE payments ADD COLUMN source TEXT NOT NULL DEFAULT 'client_card'"],
    ['provider', "ALTER TABLE payments ADD COLUMN provider TEXT NOT NULL DEFAULT 'mock'"],
    ['provider_ref', 'ALTER TABLE payments ADD COLUMN provider_ref TEXT'],
    ['amount', 'ALTER TABLE payments ADD COLUMN amount REAL'],
    ['currency', "ALTER TABLE payments ADD COLUMN currency TEXT NOT NULL DEFAULT 'THB'"],
    ['type', "ALTER TABLE payments ADD COLUMN type TEXT NOT NULL DEFAULT 'deposit'"],
    ['status', "ALTER TABLE payments ADD COLUMN status TEXT NOT NULL DEFAULT 'paid'"],
    ['created_at', 'ALTER TABLE payments ADD COLUMN created_at TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_job_type_unique
     ON payments(job_id, type)`
  ).run();

  await env.DB.prepare(
    `CREATE INDEX IF NOT EXISTS idx_payments_payer_status
     ON payments(payer_user_id, status, type)`
  ).run();
}

export async function createRefundPayment(jobId: string, env: any) {
  await ensureJobsSchema(env);
  await ensurePaymentsSchema(env);

  const job = await getJob(jobId, env);
  if (!job) throw new Error('Job not found');

  const deposit = await getPaidDeposit(jobId, env);
  if (!deposit) throw new Error('Paid deposit not found');

  const existingRefund = await getPaymentByType(jobId, 'refund', env);
  if (existingRefund) return existingRefund;

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

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
      id,
      jobId,
      job.client_user_id,
      job.client_user_id,
      deposit.payment_method_id ?? null,
      'client',
      deposit.source ?? 'client_card',
      deposit.provider ?? 'mock',
      `refund_${deposit.id}`,
      -Math.abs(deposit.amount),
      deposit.currency,
      'refund',
      'paid',
      now
    )
    .run();

  return {
    id,
    job_id: jobId,
    client_user_id: job.client_user_id,
    payer_user_id: job.client_user_id,
    payment_method_id: deposit.payment_method_id ?? null,
    payer_role: 'client',
    source: deposit.source ?? 'client_card',
    provider: deposit.provider ?? 'mock',
    provider_ref: `refund_${deposit.id}`,
    amount: -Math.abs(deposit.amount),
    currency: deposit.currency,
    type: 'refund',
    status: 'paid',
    created_at: now,
  };
}

export async function createDeposit(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensurePaymentsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const clientUserId = auth.userId;
  const job = await getJob(jobId, env);

  if (!job) return fail('Job not found', 404);

  if (job.client_user_id !== clientUserId) {
    return fail('Only job client can pay deposit', 403);
  }

  if (typeof job.price !== 'number' || job.price <= 0) {
    return fail('Job price must be set before payment', 400);
  }

  const depositAmount =
    typeof job.deposit_amount === 'number' && job.deposit_amount > 0
      ? job.deposit_amount
      : Math.round(job.price * 0.40);

  const existingPaidDeposit = await getPaidDeposit(jobId, env);
  if (existingPaidDeposit) {
    return Response.json({
      success: true,
      data: paymentData(existingPaidDeposit, jobId, job.status),
    });
  }

  if (job.status !== JOB_STATUS.awaiting_payment) {
    return fail('Deposit can be paid only for awaiting_payment job', 400);
  }

  try {
    assertTransition(job.status, JOB_STATUS.open);
  } catch (error: any) {
    return fail(error?.message ?? 'Invalid status transition', 400);
  }

  const clientPaymentMethod = await env.DB.prepare(
    `SELECT id, provider, provider_payment_method_id
     FROM payment_methods
     WHERE user_id = ?1
       AND status = 'active'
     ORDER BY is_default DESC, created_at ASC
     LIMIT 1`
  )
    .bind(clientUserId)
    .first();

  if (!clientPaymentMethod) {
    return fail('Active client payment method required for deposit payment', 400);
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const currency = job.currency || 'THB';

  try {
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
        id,
        jobId,
        clientUserId,
        clientUserId,
        clientPaymentMethod.id,
        'client',
        'client_card',
        clientPaymentMethod.provider ?? 'mock',
        `mock_charge_${id}`,
        depositAmount,
        currency,
        'deposit',
        'paid',
        now
      )
      .run();
  } catch (error: any) {
    const message = error?.message ?? 'Failed to create deposit';

    if (message.toLowerCase().includes('unique')) {
      const existing = await getPaymentByType(jobId, 'deposit', env);

      return Response.json({
        success: true,
        data: paymentData(
          {
            id: existing?.id ?? null,
            amount: existing?.amount ?? depositAmount,
            currency: existing?.currency ?? currency,
          },
          jobId,
          JOB_STATUS.open
        ),
      });
    }

    return fail(message, 500);
  }

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2,
         deposit_amount = ?3
     WHERE id = ?4`
  )
    .bind(JOB_STATUS.open, now, depositAmount, jobId)
    .run();

  const createdPayment = await env.DB.prepare(
    'SELECT * FROM payments WHERE id = ?1 LIMIT 1'
  )
    .bind(id)
    .first();

  return Response.json({
    success: true,
    data: paymentData(
      createdPayment ?? {
        id,
        client_user_id: clientUserId,
        payer_user_id: clientUserId,
        payment_method_id: clientPaymentMethod.id,
        payer_role: 'client',
        source: 'client_card',
        provider: clientPaymentMethod.provider ?? 'mock',
        provider_ref: `mock_charge_${id}`,
        amount: depositAmount,
        currency,
        status: 'paid',
        created_at: now,
      },
      jobId,
      JOB_STATUS.open
    ),
  });
}

export async function getPayments(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensurePaymentsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const actorUserId = auth.userId;
  const job = await getJob(jobId, env);

  if (!job) return fail('Job not found', 404);

  const isAdmin = auth.role === 'admin';
  const isParticipant =
    actorUserId === job.client_user_id ||
    actorUserId === job.selected_master_user_id;

  if (!isAdmin && !isParticipant) {
    return fail('Only job participants or admin can view payments', 403);
  }

  const result = await env.DB.prepare(
    'SELECT * FROM payments WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return ok(result.results ?? []);
}
