export async function selectOffer(jobId: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.offer_id) {
    return Response.json(
      { success: false, error: 'offer_id is required' },
      { status: 400 }
    );
  }

  const offer = await env.DB.prepare(
    'SELECT * FROM offers WHERE id = ?1 AND job_id = ?2'
  )
    .bind(body.offer_id, jobId)
    .first();

  if (!offer) {
    return Response.json(
      { success: false, error: 'Offer not found for this job' },
      { status: 404 }
    );
  }

  await env.DB.prepare(
    'UPDATE jobs SET selected_offer_id = ?1, selected_master_name = ?2, selected_master_user_id = ?3, status = ?4 WHERE id = ?5'
  )
    .bind(
      offer.id,
      offer.master_name,
      offer.master_user_id,
      'master_selected',
      jobId
    )
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      selected_offer_id: offer.id,
      selected_master_name: offer.master_name,
      selected_master_user_id: offer.master_user_id,
      status: 'master_selected',
    },
  });
}
