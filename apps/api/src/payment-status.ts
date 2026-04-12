import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { JOB_STATUS } from './job-status';

async function ensurePaymentsSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS payments (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      client_user_id TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      type TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`
  ).run();
}

export async function getJobPaymentStatus(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensurePaymentsSchema(env);

  const auth = requireRequestUserId(request);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  const isParticipant =
    actorUserId === job.client_user_id ||
    actorUserId === job.selected_master_user_id;

  if (!isParticipant) {
    return Response.json(
      { success: false, error: 'Only job participants can view payment status' },
      { status: 403 }
    );
  }

  const deposit = await env.DB.prepare(
    `SELECT *
     FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  const hasDeposit = !!deposit;
  const depositPaid = deposit?.status === 'paid';

  let paymentStatus = 'unpaid';
  if (deposit) {
    paymentStatus = deposit.status ?? 'unknown';
  } else if (
    job.status === JOB_STATUS.open ||
    job.status === JOB_STATUS.master_selected ||
    job.status === JOB_STATUS.in_progress ||
    job.status === JOB_STATUS.completed ||
    job.status === JOB_STATUS.disputed ||
    job.status === JOB_STATUS.cancelled
  ) {
    paymentStatus = 'missing_required_deposit';
  }

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      job_status: job.status,
      has_deposit: hasDeposit,
      deposit_paid: depositPaid,
      deposit_amount: deposit?.amount ?? null,
      deposit_currency: deposit?.currency ?? null,
      payment_status: paymentStatus,
      paid_at: deposit?.created_at ?? null,
    },
  });
}
