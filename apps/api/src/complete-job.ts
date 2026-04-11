import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';

export async function completeJob(jobId: string, request: Request, env: any) {
  let body: any = {};

  try {
    body = await request.json();
  } catch {
    body = {};
  }

  const auth = requireRequestUserId(request, {
    body,
    bodyFields: ['actor_user_id'],
  });

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
  const isSelectedMaster = actorUserId === job.selected_master_user_id;

  if (!isClient && !isSelectedMaster) {
    return Response.json(
      { success: false, error: 'Only job participants can complete job' },
      { status: 403 }
    );
  }

  if (
    job.status !== JOB_STATUS.master_selected &&
    job.status !== JOB_STATUS.in_progress
  ) {
    return Response.json(
      {
        success: false,
        error: 'Job can be completed only from master_selected or in_progress status',
      },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.completed);
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
    .bind(JOB_STATUS.completed, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      status: JOB_STATUS.completed,
      updated_at: now,
    },
  });
}
