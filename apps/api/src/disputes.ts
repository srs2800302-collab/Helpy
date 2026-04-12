import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';

type CreateDisputeBody = {
  reason?: string;
};

async function ensureDisputesSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS disputes (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      created_by_user_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
     ON disputes(job_id)`
  ).run();
}

function canCreateDisputeInStatus(status: string) {
  return status === JOB_STATUS.master_selected || status === JOB_STATUS.in_progress;
}

export async function createDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

  let body: CreateDisputeBody;
  try {
    body = await request.json() as CreateDisputeBody;
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

  const actorUserId = auth.userId;

  if (!body.reason || !body.reason.toString().trim()) {
    return Response.json(
      { success: false, error: 'reason is required' },
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

  const isClient = actorUserId === job.client_user_id;
  const isSelectedMaster =
    !!job.selected_master_user_id &&
    actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return Response.json(
      { success: false, error: 'Only job participants can create dispute' },
      { status: 403 }
    );
  }

  const existingDispute = await env.DB.prepare(
    'SELECT * FROM disputes WHERE job_id = ?1 LIMIT 1'
  )
    .bind(jobId)
    .first();

  if (existingDispute) {
    return Response.json(
      { success: false, error: 'Dispute already exists for this job' },
      { status: 409 }
    );
  }

  if (!canCreateDisputeInStatus(job.status)) {
    return Response.json(
      {
        success: false,
        error: 'Dispute can be created only for master_selected or in_progress job',
      },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.disputed);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const reason = body.reason.toString().trim();

  try {
    await env.DB.prepare(
      `INSERT INTO disputes (
        id,
        job_id,
        created_by_user_id,
        reason,
        status,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
    )
      .bind(
        id,
        jobId,
        actorUserId,
        reason,
        'open',
        now
      )
      .run();
  } catch (error: any) {
    const message = error?.message ?? 'Failed to create dispute';

    if (message.toLowerCase().includes('unique')) {
      return Response.json(
        { success: false, error: 'Dispute already exists for this job' },
        { status: 409 }
      );
    }

    return Response.json(
      { success: false, error: message },
      { status: 500 }
    );
  }

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind(JOB_STATUS.disputed, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      created_by_user_id: actorUserId,
      reason,
      status: 'open',
      job_status: JOB_STATUS.disputed,
      created_at: now,
    },
  });
}

export async function getDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

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

  const isClient = actorUserId === job.client_user_id;
  const isSelectedMaster =
    !!job.selected_master_user_id &&
    actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return Response.json(
      { success: false, error: 'Only job participants can view dispute' },
      { status: 403 }
    );
  }

  const dispute = await env.DB.prepare(
    'SELECT * FROM disputes WHERE job_id = ?1 LIMIT 1'
  )
    .bind(jobId)
    .first();

  if (!dispute) {
    return Response.json(
      { success: false, error: 'Dispute not found for this job' },
      { status: 404 }
    );
  }

  return Response.json({
    success: true,
    data: dispute,
  });
}
