import { requireRequestUserId } from './auth-context';

type CreateReviewBody = {
  master_user_id?: string;
  rating?: number;
  comment?: string;
};

async function ensureReviewsSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS reviews (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      client_user_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      rating INTEGER NOT NULL,
      comment TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  const columns = await env.DB.prepare('PRAGMA table_info(reviews)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['client_user_id', 'ALTER TABLE reviews ADD COLUMN client_user_id TEXT'],
    ['master_user_id', 'ALTER TABLE reviews ADD COLUMN master_user_id TEXT'],
    ['rating', 'ALTER TABLE reviews ADD COLUMN rating INTEGER'],
    ['comment', 'ALTER TABLE reviews ADD COLUMN comment TEXT'],
    ['created_at', 'ALTER TABLE reviews ADD COLUMN created_at TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }
}

export async function getReviews(jobId: string, env: any) {
  await ensureReviewsSchema(env);

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
  await ensureReviewsSchema(env);

  let body: CreateReviewBody;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = requireRequestUserId(request);

  if (!auth.ok) {
    return auth.response;
  }

  const clientUserId = auth.userId;

  if (
    !body.master_user_id ||
    typeof body.rating !== 'number'
  ) {
    return Response.json(
      {
        success: false,
        error: 'master_user_id and rating are required',
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

  if (job.client_user_id !== clientUserId) {
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

  try {
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
        clientUserId,
        body.master_user_id,
        body.rating,
        body.comment ?? null,
        now
      )
      .run();
  } catch (error: any) {
    return Response.json(
      {
        success: false,
        error: error?.message ?? 'Failed to create review',
      },
      { status: 500 }
    );
  }

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      client_user_id: clientUserId,
      master_user_id: body.master_user_id,
      rating: body.rating,
      comment: body.comment ?? null,
      created_at: now,
    },
  });
}
