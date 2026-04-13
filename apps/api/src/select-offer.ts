import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { fail } from './response';

async function ensureOffersSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS offers (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      master_name TEXT NOT NULL,
      price REAL NOT NULL,
      comment TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();
}

export async function selectOffer(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureOffersSchema(env);

  const auth = requireRequestUserId(request);
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
      jobId,
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
