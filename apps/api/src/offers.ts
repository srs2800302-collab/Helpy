import { requireRequestUserId } from './auth-context';

type CreateOfferBody = {
  master_name?: string;
  price?: number;
};

async function ensureOffersSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS offers (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      master_name TEXT NOT NULL,
      price REAL NOT NULL,
      comment TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_job_master_unique
     ON offers(job_id, master_user_id)`
  ).run();
}

export async function createOffer(jobId: string, request: Request, env: any) {
  await ensureOffersSchema(env);

  let body: CreateOfferBody;

  try {
    body = await request.json() as CreateOfferBody;
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

  const masterUserId = auth.userId;

  if (
    !body.master_name ||
    typeof body.price !== 'number' ||
    body.price <= 0
  ) {
    return Response.json(
      {
        success: false,
        error: 'master_name and positive price are required',
      },
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

  if (job.client_user_id === masterUserId) {
    return Response.json(
      { success: false, error: 'Master cannot create offer for own job' },
      { status: 400 }
    );
  }

  if (job.status !== 'open') {
    return Response.json(
      { success: false, error: 'Offers can be created only for open jobs' },
      { status: 400 }
    );
  }

  try {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();

    await env.DB.prepare(
      `INSERT INTO offers (
        id,
        job_id,
        master_user_id,
        master_name,
        price,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
    )
      .bind(
        id,
        jobId,
        masterUserId,
        body.master_name.trim(),
        body.price,
        now
      )
      .run();

    return Response.json(
      {
        success: true,
        data: {
          id,
          job_id: jobId,
          master_user_id: masterUserId,
          master_name: body.master_name.trim(),
          price: body.price,
          created_at: now,
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    const message = error?.message ?? 'Failed to create offer';

    if (message.toLowerCase().includes('unique')) {
      return Response.json(
        { success: false, error: 'Master already has an offer for this job' },
        { status: 409 }
      );
    }

    return Response.json(
      {
        success: false,
        error: message,
      },
      { status: 500 }
    );
  }
}

export async function getOffers(jobId: string, env: any) {
  await ensureOffersSchema(env);

  const result = await env.DB.prepare(
    'SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
