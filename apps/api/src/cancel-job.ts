import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';

function getRefundPolicy(status: string) {
  if (status === JOB_STATUS.draft || status === JOB_STATUS.awaiting_payment) {
    return 'no_payment';
  }

  if (status === JOB_STATUS.open) {
    return 'no_refund';
  }

  return null;
}

export async function cancelJob(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  try {
    await request.json();
  } catch {
    // empty body is allowed
  }

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

  if (actorUserId !== job.client_user_id) {
    return Response.json(
      { success: false, error: 'Only job client can cancel job' },
      { status: 403 }
    );
  }

  if (job.status === JOB_STATUS.cancelled) {
    return Response.json(
      { success: false, error: 'Job is already cancelled' },
      { status: 409 }
    );
  }

  if (job.status === JOB_STATUS.completed) {
    return Response.json(
      { success: false, error: 'Completed job cannot be cancelled' },
      { status: 400 }
    );
  }

  if (
    job.status === JOB_STATUS.master_selected ||
    job.status === JOB_STATUS.in_progress ||
    job.status === JOB_STATUS.disputed
  ) {
    return Response.json(
      {
        success: false,
        error: 'Job cannot be cancelled after master selection. Use dispute flow.',
      },
      { status: 400 }
    );
  }

  const allowedStatuses = new Set([
    JOB_STATUS.draft,
    JOB_STATUS.awaiting_payment,
    JOB_STATUS.open,
  ]);

  if (!allowedStatuses.has(job.status)) {
    return Response.json(
      { success: false, error: 'Job cannot be cancelled from current status' },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.cancelled);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const now = new Date().toISOString();
  const refundPolicy = getRefundPolicy(job.status);

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind(JOB_STATUS.cancelled, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      status: JOB_STATUS.cancelled,
      cancelled_by_user_id: actorUserId,
      refund_policy: refundPolicy,
      updated_at: now,
    },
  });
}
