export async function getJobsByStatus(userId: string, env: any) {
  const openResult = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE client_user_id = ?1 AND status = 'open'
     ORDER BY created_at DESC`
  )
    .bind(userId)
    .all();

  const masterSelectedResult = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE client_user_id = ?1 AND status = 'master_selected'
     ORDER BY created_at DESC`
  )
    .bind(userId)
    .all();

  const completedResult = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE client_user_id = ?1 AND status = 'completed'
     ORDER BY created_at DESC`
  )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: {
      open: openResult.results ?? [],
      master_selected: masterSelectedResult.results ?? [],
      completed: completedResult.results ?? [],
    },
  });
}
