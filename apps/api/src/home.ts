function buildJobActions(status: string, hasSelectedMaster: boolean, hasReview: boolean) {
  switch (status) {
    case 'open':
      return ['view_offers'];
    case 'master_selected':
      return hasSelectedMaster
        ? ['view_selected_master', 'complete_job']
        : ['complete_job'];
    case 'in_progress':
      return hasSelectedMaster
        ? ['view_selected_master', 'complete_job']
        : ['complete_job'];
    case 'completed':
      return hasReview ? ['view_review'] : ['leave_review'];
    default:
      return [];
  }
}

export async function getClientHome(userId: string, env: any) {
  const totalJobsRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1'
  )
    .bind(userId)
    .first();

  const openJobsRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = ?2'
  )
    .bind(userId, 'open')
    .first();

  const masterSelectedJobsRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = ?2'
  )
    .bind(userId, 'master_selected')
    .first();

  const completedJobsRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = ?2'
  )
    .bind(userId, 'completed')
    .first();

  const pendingReviewJobsRow = await env.DB.prepare(
    `SELECT COUNT(*) as count
     FROM jobs j
     WHERE j.client_user_id = ?1
       AND j.status = 'completed'
       AND NOT EXISTS (
         SELECT 1
         FROM reviews r
         WHERE r.job_id = j.id
       )`
  )
    .bind(userId)
    .first();

  const recentJobsResult = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE client_user_id = ?1
     ORDER BY created_at DESC
     LIMIT 5`
  )
    .bind(userId)
    .all();

  const recentJobs = recentJobsResult.results ?? [];

  const actionRequiredJobs = [];

  for (const job of recentJobs) {
    const review = await env.DB.prepare(
      'SELECT id FROM reviews WHERE job_id = ?1 LIMIT 1'
    )
      .bind(job.id)
      .first();

    const actions = buildJobActions(
      job.status,
      !!job.selected_master_user_id,
      !!review
    );

    if (actions.length > 0) {
      actionRequiredJobs.push({
        id: job.id,
        title: job.title,
        status: job.status,
        actions,
      });
    }
  }

  return Response.json({
    success: true,
    data: {
      dashboard: {
        total_jobs: Number(totalJobsRow?.count ?? 0),
        open_jobs: Number(openJobsRow?.count ?? 0),
        master_selected_jobs: Number(masterSelectedJobsRow?.count ?? 0),
        completed_jobs: Number(completedJobsRow?.count ?? 0),
        pending_review_jobs: Number(pendingReviewJobsRow?.count ?? 0),
      },
      recent_jobs: recentJobs,
      action_required_jobs: actionRequiredJobs,
    },
  });
}
