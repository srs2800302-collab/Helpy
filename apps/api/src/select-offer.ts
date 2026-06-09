import { assertRequiredTable } from './schema-guards';
import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { fail } from './response';
import { OFFER_COLUMNS, selectJobById } from './job-enrichment';
import { OFFER_STATUS } from './db-domains';

export async function selectOffer(jobId: string, request: Request, env: any) {
  await assertRequiredTable(env, 'jobs');
  await assertRequiredTable(env, 'offers');
  await assertRequiredTable(env, 'payments');
  await assertRequiredTable(env, 'job_events');

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

  const job = await selectJobById(env, jobId);

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
    `SELECT ${OFFER_COLUMNS} FROM offers WHERE id = ?1 AND job_id = ?2`
  )
    .bind(body.offer_id, jobId)
    .first();

  if (!offer) {
    return fail('Offer not found for this job', 404);
  }

  if ((offer.status ?? OFFER_STATUS.active) !== OFFER_STATUS.active) {
    return fail('Offer is no longer active', 400);
  }

  const now = new Date().toISOString();

  const selectedDepositAmount = Math.round(Number(offer.price) * 0.3 * 100) / 100;
  const commissionPayer = job.payment_method === 'cash' ? 'master' : 'client';
  const nextStatus =
    commissionPayer === 'master'
      ? JOB_STATUS.master_selected
      : JOB_STATUS.awaiting_payment;

  await env.DB.prepare(
    `UPDATE jobs
     SET selected_offer_id = ?1,
         selected_master_name = ?2,
         selected_master_user_id = ?3,
         selected_offer_price = ?4,
         status = ?5,
         updated_at = ?6,
         deposit_amount = ?7
     WHERE id = ?8`
  )
    .bind(
      offer.id,
      offer.master_name,
      offer.master_user_id,
      offer.price,
      nextStatus,
      now,
      selectedDepositAmount,
      jobId
    )
    .run();

  if (nextStatus === JOB_STATUS.master_selected) {
    await env.DB.prepare(
      `INSERT INTO job_events (
        id,
        job_id,
        event_type,
        actor_user_id,
        actor_role,
        payload_json,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
    )
      .bind(
        crypto.randomUUID(),
        jobId,
        'master_selected',
        auth.userId,
        'client',
        JSON.stringify({
          offer_id: offer.id,
          master_user_id: offer.master_user_id,
          master_name: offer.master_name,
          selected_offer_price: offer.price,
          from_status: JOB_STATUS.open,
          to_status: nextStatus,
        }),
        now,
      )
      .run();
  }

  await env.DB.prepare(
    `UPDATE offers
     SET status = CASE WHEN id = ?1 THEN ?3 ELSE ?4 END
     WHERE job_id = ?2
       AND COALESCE(status, ?5) = ?5`
  )
    .bind(offer.id, jobId, OFFER_STATUS.selected, OFFER_STATUS.rejected, OFFER_STATUS.active)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      selected_offer_id: offer.id,
      selected_master_name: offer.master_name,
      selected_master_user_id: offer.master_user_id,
      selected_offer_price: offer.price,
      status: nextStatus,
      updated_at: now,
    },
  });
}
