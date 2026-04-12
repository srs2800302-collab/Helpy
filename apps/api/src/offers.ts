type CreateOfferBody = {
  master_user_id?: string;
  master_name?: string;
  price?: number;
};

export async function createOffer(jobId: string, request: Request, env: any) {
  let body: CreateOfferBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (
    !body.master_user_id ||
    !body.master_name ||
    typeof body.price !== 'number' ||
    body.price <= 0
  ) {
    return Response.json(
      {
        success: false,
        error: 'master_user_id, master_name and positive price are required',
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

  if (job.client_user_id === body.master_user_id) {
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

  const existing = await env.DB.prepare(
    `SELECT * FROM offers
     WHERE job_id = ?1 AND master_user_id = ?2
     LIMIT 1`
  )
    .bind(jobId, body.master_user_id)
    .first();

  if (existing) {
    return Response.json(
      { success: false, error: 'Master already has an offer for this job' },
      { status: 409 }
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
        body.master_user_id,
        body.master_name,
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
          master_user_id: body.master_user_id,
          master_name: body.master_name,
          price: body.price,
          created_at: now,
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    return Response.json(
      {
        success: false,
        error: error?.message ?? 'Failed to create offer',
      },
      { status: 500 }
    );
  }
}

export async function getOffers(jobId: string, env: any) {
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
