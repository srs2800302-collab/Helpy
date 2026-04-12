import { JOB_STATUS, assertTransition } from './job-status';
import { ensureJobsSchema } from './jobs';
import { requireRequestUserId } from './auth-context';

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

  const columns = await env.DB.prepare('PRAGMA table_info(payments)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['job_id', 'ALTER TABLE payments ADD COLUMN job_id TEXT'],
    ['client_user_id', 'ALTER TABLE payments ADD COLUMN client_user_id TEXT'],
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
}

export async function createDeposit(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensurePaymentsSchema(env);

  let body: any;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = requireRequestUserId(request);

  if (!auth.ok) {
    return auth.response;
  }

  const clientUserId = auth.userId;

  if (typeof body.amount !== 'number' || body.amount <= 0) {
    return Response.json(
      { success: false, error: 'amount must be a positive number' },
      { status: 400 }
    );
  }

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

  if (job.client_user_id !== clientUserId) {
    return Response.json(
      { success: false, error: 'Only job client can pay deposit' },
      { status: 403 }
    );
  }

  const existingPaidDeposit = await env.DB.prepare(
    `SELECT * FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
       AND status = 'paid'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  if (existingPaidDeposit) {
    return Response.json({
      success: true,
      data: {
        id: existingPaidDeposit.id,
        job_id: jobId,
        amount: existingPaidDeposit.amount,
        currency: existingPaidDeposit.currency,
        status: 'paid',
        job_status: job.status,
      },
    });
  }

  if (
    job.status !== JOB_STATUS.draft &&
    job.status !== JOB_STATUS.awaiting_payment
  ) {
    return Response.json(
      {
        success: false,
        error: 'Deposit can be paid only for draft or awaiting_payment job',
      },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.open);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO payments (
      id,
      job_id,
      client_user_id,
      amount,
      currency,
      type,
      status,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)`
  )
    .bind(
      id,
      jobId,
      clientUserId,
      body.amount,
      body.currency || 'THB',
      'deposit',
      'paid',
      now
    )
    .run();

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind(JOB_STATUS.open, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      amount: body.amount,
      currency: body.currency || 'THB',
      status: 'paid',
      job_status: JOB_STATUS.open,
      created_at: now,
    },
  });
}

export async function getPayments(jobId: string, request: Request, env: any) {
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
      { success: false, error: 'Only job participants can view payments' },
      { status: 403 }
    );
  }

  const result = await env.DB.prepare(
    'SELECT * FROM payments WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
