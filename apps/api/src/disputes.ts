import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';import { createRefundPayment } from './payments';

type CreateDisputeBody = {
  reason?: string;
};

type ResolveDisputeBody = {
  resolution?: 'refund' | 'no_refund';
};

async function ensureDisputesSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS disputes (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      created_by_user_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      status TEXT NOT NULL,
      resolution TEXT,
      resolved_by_user_id TEXT,
      resolved_at TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  const columns = await env.DB.prepare('PRAGMA table_info(disputes)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['resolution', 'ALTER TABLE disputes ADD COLUMN resolution TEXT'],
    ['resolved_by_user_id', 'ALTER TABLE disputes ADD COLUMN resolved_by_user_id TEXT'],
    ['resolved_at', 'ALTER TABLE disputes ADD COLUMN resolved_at TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }

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

  if (body.resolution === 'refund') {
    try {
      await createRefundPayment(jobId, env);
    } catch (error: any) {
      return Response.json(
        { success: false, error: error?.message ?? 'Failed to create refund payment' },
        { status: 500 }
      );
    }
  }
  const reason = body.reason.toString().trim();

  await env.DB.prepare(
    `INSERT INTO disputes (
      id, job_id, created_by_user_id, reason, status,
      resolution, resolved_by_user_id, resolved_at, created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)`
  )
    .bind(id, jobId, actorUserId, reason, 'open', null, null, null, now)
    .run();

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
      resolution: null,
      resolved_by_user_id: null,
      resolved_at: null,
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

export async function resolveDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

  let body: ResolveDisputeBody;
  try {
    body = await request.json() as ResolveDisputeBody;
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

  const resolverUserId = auth.userId;

  const resolver = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?1 LIMIT 1'
  )
    .bind(resolverUserId)
    .first();

  if (!resolver) {
    return Response.json(
      { success: false, error: 'Resolver user not found' },
      { status: 404 }
    );
  }

  if (resolver.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can resolve dispute' },
      { status: 403 }
    );
  }

  if (body.resolution !== 'refund' && body.resolution !== 'no_refund') {
    return Response.json(
      { success: false, error: 'resolution must be refund or no_refund' },
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

  if (job.status !== JOB_STATUS.disputed) {
    return Response.json(
      { success: false, error: 'Only disputed job can be resolved' },
      { status: 400 }
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

  if (dispute.status === 'resolved') {
    return Response.json(
      { success: false, error: 'Dispute is already resolved' },
      { status: 409 }
    );
  }

  const targetJobStatus =
    body.resolution === 'refund' ? JOB_STATUS.cancelled : JOB_STATUS.completed;

  try {
    assertTransition(job.status, targetJobStatus);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const now = new Date().toISOString();

  if (body.resolution === 'refund') {
    try {
      await createRefundPayment(jobId, env);
    } catch (error: any) {
      return Response.json(
        { success: false, error: error?.message ?? 'Failed to create refund payment' },
        { status: 500 }
      );
    }
  }

  await env.DB.prepare(
    `UPDATE disputes
     SET status = ?1,
         resolution = ?2,
         resolved_by_user_id = ?3,
         resolved_at = ?4
     WHERE job_id = ?5`
  )
    .bind('resolved', body.resolution, resolverUserId, now, jobId)
    .run();

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind(targetJobStatus, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      dispute_status: 'resolved',
      resolution: body.resolution,
      resolved_by_user_id: resolverUserId,
      resolved_at: now,
      job_status: targetJobStatus,
    },
  });
}
