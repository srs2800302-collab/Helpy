import { JOB_STATUS, assertTransition } from './job-status';
import { ensureJobsSchema } from './jobs';

export async function createDeposit(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  let body: any;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (!body.client_user_id) {
    return Response.json(
      { success: false, error: 'client_user_id is required' },
      { status: 400 }
    );
  }

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

  if (job.client_user_id !== body.client_user_id) {
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
      body.client_user_id,
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

export async function getPayments(jobId: string, env: any) {
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
