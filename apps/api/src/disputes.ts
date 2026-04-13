import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { createRefundPayment } from './payments';
import { ok, fail } from './response';

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

async function getJob(jobId: string, env: any) {
  return env.DB.prepare('SELECT * FROM jobs WHERE id = ?1').bind(jobId).first();
}

async function getDisputeRecord(jobId: string, env: any) {
  return env.DB.prepare('SELECT * FROM disputes WHERE job_id = ?1 LIMIT 1').bind(jobId).first();
}

export async function createDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

  let body: CreateDisputeBody;
  try {
    body = await request.json() as CreateDisputeBody;
  } catch {
    return fail('Invalid JSON body', 400);
  }

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const actorUserId = auth.userId;
  const reason = body.reason?.toString().trim();

  if (!reason) return fail('reason is required', 400);

  const job = await getJob(jobId, env);
  if (!job) return fail('Job not found', 404);

  const isClient = actorUserId === job.client_user_id;
  const isSelectedMaster =
    !!job.selected_master_user_id &&
    actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return fail('Only job participants can create dispute', 403);
  }

  const existingDispute = await getDisputeRecord(jobId, env);
  if (existingDispute) {
    return fail('Dispute already exists for this job', 409);
  }

  if (!canCreateDisputeInStatus(job.status)) {
    return fail('Dispute can be created only for master_selected or in_progress job', 400);
  }

  try {
    assertTransition(job.status, JOB_STATUS.disputed);
  } catch (error: any) {
    return fail(error?.message ?? 'Invalid status transition', 400);
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

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

  return ok({
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
  });
}

export async function getDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const actorUserId = auth.userId;
  const job = await getJob(jobId, env);

  if (!job) return fail('Job not found', 404);

  const isClient = actorUserId === job.client_user_id;
  const isSelectedMaster =
    !!job.selected_master_user_id &&
    actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return fail('Only job participants can view dispute', 403);
  }

  const dispute = await getDisputeRecord(jobId, env);
  if (!dispute) return fail('Dispute not found for this job', 404);

  return ok(dispute);
}

export async function resolveDispute(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureDisputesSchema(env);

  let body: ResolveDisputeBody;
  try {
    body = await request.json() as ResolveDisputeBody;
  } catch {
    return fail('Invalid JSON body', 400);
  }

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const resolverUserId = auth.userId;
  const resolver = auth.user;

  if (resolver.role !== 'admin') {
    return fail('Only admin can resolve dispute', 403);
  }

  if (body.resolution !== 'refund' && body.resolution !== 'no_refund') {
    return fail('resolution must be refund or no_refund', 400);
  }

  const job = await getJob(jobId, env);
  if (!job) return fail('Job not found', 404);

  if (job.status !== JOB_STATUS.disputed) {
    return fail('Only disputed job can be resolved', 400);
  }

  const dispute = await getDisputeRecord(jobId, env);
  if (!dispute) return fail('Dispute not found for this job', 404);
  if (dispute.status === 'resolved') return fail('Dispute is already resolved', 409);

  const targetJobStatus =
    body.resolution === 'refund' ? JOB_STATUS.cancelled : JOB_STATUS.completed;

  try {
    assertTransition(job.status, targetJobStatus);
  } catch (error: any) {
    return fail(error?.message ?? 'Invalid status transition', 400);
  }

  const now = new Date().toISOString();

  if (body.resolution === 'refund') {
    const existingRefund = await env.DB.prepare(
      "SELECT * FROM payments WHERE job_id = ?1 AND type = 'refund' LIMIT 1"
    )
      .bind(jobId)
      .first();

    if (!existingRefund) {
      try {
        await createRefundPayment(jobId, env);
      } catch (error: any) {
        return fail(error?.message ?? 'Failed to create refund payment', 500);
      }
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

  return ok({
    job_id: jobId,
    dispute_status: 'resolved',
    resolution: body.resolution,
    resolved_by_user_id: resolverUserId,
    resolved_at: now,
    job_status: targetJobStatus,
  });
}
