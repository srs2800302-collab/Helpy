export async function getOffersByMaster(userId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM offers WHERE master_user_id = ?1 ORDER BY created_at DESC'
  )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}

export async function getAvailableJobsForMaster(userId: string, env: any) {
  const result = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE status = ?1
       AND id NOT IN (
         SELECT job_id
         FROM offers
         WHERE master_user_id = ?2
       )
     ORDER BY created_at DESC`
  )
    .bind('open', userId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
