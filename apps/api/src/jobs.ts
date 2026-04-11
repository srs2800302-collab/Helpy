type CreateJobBody = {
  title?: string;
  price?: number;
  category?: string;
  client_user_id?: string;
};

export async function getJobs(env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs ORDER BY created_at DESC'
  ).all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}

export async function getJobById(id: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  if (!result) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  return Response.json({
    success: true,
    data: result,
  });
}

export async function createJob(request: Request, env: any) {
  let body: CreateJobBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (
    !body.title ||
    !body.category ||
    typeof body.price !== 'number' ||
    !body.client_user_id
  ) {
    return Response.json(
      {
        success: false,
        error: 'title, category, price, client_user_id are required',
      },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO jobs (id, title, price, category, status, created_at, client_user_id) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)'
  )
    .bind(
      id,
      body.title,
      body.price,
      body.category,
      'open',
      new Date().toISOString(),
      body.client_user_id
    )
    .run();

  return Response.json(
    {
      success: true,
      data: {
        id,
        title: body.title,
        price: body.price,
        category: body.category,
        client_user_id: body.client_user_id,
        status: 'open',
      },
    },
    { status: 201 }
  );
}

export async function updateJobStatus(id: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.status) {
    return Response.json(
      { success: false, error: 'status is required' },
      { status: 400 }
    );
  }

  await env.DB.prepare(
    'UPDATE jobs SET status = ?1 WHERE id = ?2'
  )
    .bind(body.status, id)
    .run();

  return Response.json({
    success: true,
    data: { id, status: body.status },
  });
}

export async function getJobsByUser(userId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE client_user_id = ?1 ORDER BY created_at DESC'
  )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
