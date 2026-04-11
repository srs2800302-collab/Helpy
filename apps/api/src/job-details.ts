export async function getUserJobDetails(userId: string, jobId: string, env: any) {
  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1 AND client_user_id = ?2'
  )
    .bind(jobId, userId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found for this user' },
      { status: 404 }
    );
  }

  const offersResult = await env.DB.prepare(
    'SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  const offers = offersResult.results ?? [];

  let selectedOffer = null;
  if (job.selected_offer_id) {
    selectedOffer = await env.DB.prepare(
      'SELECT * FROM offers WHERE id = ?1 LIMIT 1'
    )
      .bind(job.selected_offer_id)
      .first();
  }

  let selectedMaster = null;
  if (job.selected_master_user_id) {
    selectedMaster = await env.DB.prepare(
      `SELECT
         u.id,
         u.role,
         u.phone,
         u.language,
         mp.name,
         mp.category,
         mp.bio,
         mp.is_verified
       FROM users u
       LEFT JOIN master_profiles mp ON mp.user_id = u.id
       WHERE u.id = ?1
       LIMIT 1`
    )
      .bind(job.selected_master_user_id)
      .first();
  }

  const reviewsResult = await env.DB.prepare(
    'SELECT * FROM reviews WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: {
      job,
      offers,
      selected_offer: selectedOffer,
      selected_master: selectedMaster,
      reviews: reviewsResult.results ?? [],
    },
  });
}
