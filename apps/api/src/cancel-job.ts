import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';

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

  const isClient = actorUserId === job.client_user_id;
  const isSelectedMaster =
    !!job.selected_master_user_id &&
    actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return Response.json(
      { success: false, error: 'Only job participants can cancel job' },
      { status: 403 }
    );
  }

  if (job.status === JOB_STATUS.completed) {
    return Response.json(
      { success: false, error: 'Completed job cannot be cancelled' },
      { status: 400 }
    );
  }

  if (job.status === JOB_STATUS.cancelled) {
    return Response.json(
      { success: false, error: 'Job is already cancelled' },
      { status: 409 }
    );
  }

  const allowedStatuses = new Set([
    JOB_STATUS.draft,
    JOB_STATUS.awaiting_payment,
    JOB_STATUS.open,
    JOB_STATUS.master_selected,
    JOB_STATUS.in_progress,
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
      updated_at: now,
    },
  });
}
