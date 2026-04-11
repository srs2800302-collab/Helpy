type CreateReviewBody = {
  rating?: number;
  comment?: string;
};

export async function createReview(jobId: string, request: Request, env: any) {
  let body: CreateReviewBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (typeof body.rating !== 'number') {
    return Response.json(
      { success: false, error: 'rating is required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO reviews (id, job_id, rating, comment, created_at) VALUES (?1, ?2, ?3, ?4, ?5)'
  )
    .bind(
      id,
      jobId,
      body.rating,
      body.comment ?? null,
      new Date().toISOString()
    )
    .run();

  return Response.json(
    {
      success: true,
      data: {
        id,
        job_id: jobId,
        rating: body.rating,
        comment: body.comment ?? null,
      },
    },
    { status: 201 }
  );
}

export async function getReviews(jobId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM reviews WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
