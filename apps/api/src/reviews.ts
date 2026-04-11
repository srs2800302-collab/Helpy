type CreateReviewBody = {
  client_user_id?: string;
  master_user_id?: string;
  rating?: number;
  comment?: string;
};

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

  if (
    !body.client_user_id ||
    !body.master_user_id ||
    typeof body.rating !== 'number'
  ) {
    return Response.json(
      {
        success: false,
        error: 'client_user_id, master_user_id and rating are required',
      },
      { status: 400 }
    );
  }

  if (body.rating < 1 || body.rating > 5) {
    return Response.json(
      { success: false, error: 'rating must be between 1 and 5' },
      { status: 400 }
    );
  }

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

  if (job.status !== 'completed') {
    return Response.json(
      { success: false, error: 'Review can be created only for completed job' },
      { status: 400 }
    );
  }

  if (job.client_user_id !== body.client_user_id) {
    return Response.json(
      { success: false, error: 'Only job client can create review' },
      { status: 403 }
    );
  }

  if (job.selected_master_user_id !== body.master_user_id) {
    return Response.json(
      { success: false, error: 'Review master does not match selected master' },
      { status: 400 }
    );
  }

  const existing = await env.DB.prepare(
    'SELECT * FROM reviews WHERE job_id = ?1 LIMIT 1'
  )
    .bind(jobId)
    .first();

  if (existing) {
    return Response.json(
      { success: false, error: 'Review already exists for this job' },
      { status: 409 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO reviews (
      id,
      job_id,
      client_user_id,
      master_user_id,
      rating,
      comment,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
  )
    .bind(
      id,
      jobId,
      body.client_user_id,
      body.master_user_id,
      body.rating,
      body.comment ?? null,
      now
    )
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      rating: body.rating,
      comment: body.comment ?? null,
      created_at: now,
    },
  });
}
