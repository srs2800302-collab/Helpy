export async function getClientDashboard(userId: string, env: any) {
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

  return Response.json({
    success: true,
    data: {
      total_jobs: Number(totalJobsRow?.count ?? 0),
      open_jobs: Number(openJobsRow?.count ?? 0),
      master_selected_jobs: Number(masterSelectedJobsRow?.count ?? 0),
      completed_jobs: Number(completedJobsRow?.count ?? 0),
      pending_review_jobs: Number(pendingReviewJobsRow?.count ?? 0),
    },
  });
}
