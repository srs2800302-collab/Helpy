export async function createOffer(jobId: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.master_name || typeof body.price !== 'number') {
    return Response.json(
      { success: false, error: 'master_name and price are required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO offers (id, job_id, master_name, price, comment, created_at) VALUES (?, ?, ?, ?, ?, ?)'
  )
    .bind(
      id,
      jobId,
      body.master_name,
      body.price,
      body.comment || null,
      new Date().toISOString()
    )
    .run();

  return Response.json({
    success: true,
    data: { id, job_id: jobId, ...body },
  }, { status: 201 });
}

export async function getOffers(jobId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM offers WHERE job_id = ? ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results,
  });
}
