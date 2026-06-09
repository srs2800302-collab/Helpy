import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { selectJobById } from './job-enrichment';

export async function confirmCompletion(jobId: string, request: Request, env: any) {
  try {
    await request.json();
  } catch {
    // empty body is allowed
  }

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;
  const job = await selectJobById(env, jobId);

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (job.client_user_id !== actorUserId) {
    return Response.json(
      { success: false, error: 'Only job client can confirm completion' },
      { status: 403 }
    );
  }

  if (job.status !== JOB_STATUS.in_progress) {
    return Response.json(
      {
        success: false,
        error: 'Completion can be confirmed only for in_progress job',
      },
      { status: 400 }
    );
  }

  const evidencePhotoCountResult = await env.DB.prepare(
    `SELECT COUNT(*) as count
     FROM job_photos
     WHERE job_id = ?1
       AND client_user_id = ?2`
  )
    .bind(jobId, job.selected_master_user_id)
    .first();

  if (Number(evidencePhotoCountResult?.count ?? 0) <= 0) {
    return Response.json(
      { success: false, error: 'Evidence photos are required before completion confirmation' },
      { status: 400 }
    );
  }

  const existingConfirmation = await env.DB.prepare(
    `SELECT id
     FROM job_events
     WHERE job_id = ?1
       AND event_type = 'completion_confirmed_by_client'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  if (existingConfirmation) {
    return Response.json(
      { success: false, error: 'Completion already confirmed by client' },
      { status: 409 }
    );
  }

  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO job_events (
       id,
       job_id,
       event_type,
       actor_user_id,
       actor_role,
       payload_json,
       created_at
     )
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
  )
    .bind(
      crypto.randomUUID(),
      jobId,
      'completion_confirmed_by_client',
      actorUserId,
      'client',
      JSON.stringify({
        from_status: JOB_STATUS.in_progress,
        to_status: JOB_STATUS.in_progress,
        evidence_photo_count: Number(evidencePhotoCountResult?.count ?? 0),
      }),
      now
    )
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      status: JOB_STATUS.in_progress,
      completion_confirmed_by_client: true,
      confirmed_at: now,
    },
  });
}

export async function completeJob(jobId: string, request: Request, env: any) {
  try {
    await request.json();
  } catch {
    // empty body is allowed
  }

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;
  const job = await selectJobById(env, jobId);

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (actorUserId !== job.selected_master_user_id) {
    return Response.json(
      { success: false, error: 'Only selected master can complete job' },
      { status: 403 }
    );
  }

  if (job.status !== JOB_STATUS.in_progress) {
    return Response.json(
      {
        success: false,
        error: 'Job can be completed only from in_progress status',
      },
      { status: 400 }
    );
  }

  const completionConfirmation = await env.DB.prepare(
    `SELECT id
     FROM job_events
     WHERE job_id = ?1
       AND event_type = 'completion_confirmed_by_client'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  if (!completionConfirmation) {
    return Response.json(
      { success: false, error: 'Client completion confirmation is required' },
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

  await env.DB.prepare(
    `INSERT INTO job_events (
       id,
       job_id,
       event_type,
       actor_user_id,
       actor_role,
       payload_json,
       created_at
     )
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
  )
    .bind(
      crypto.randomUUID(),
      jobId,
      'job_completed',
      actorUserId,
      'master',
      JSON.stringify({
        from_status: JOB_STATUS.in_progress,
        to_status: JOB_STATUS.completed,
        completed_at: now,
      }),
      now
    )
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
