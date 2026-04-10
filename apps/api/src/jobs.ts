type CreateJobBody = {
  title?: string;
  price?: number;
  category?: string;
};

export async function getJobs(env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs ORDER BY created_at DESC'
  ).all();

  return Response.json({
    success: true,
    data: result.results,
  });
}

export async function getJobById(id: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?'
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

  if (!body.title || !body.category || typeof body.price !== 'number') {
    return Response.json(
      { success: false, error: 'title, category, price are required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO jobs (id, title, price, category, status, created_at) VALUES (?, ?, ?, ?, ?, ?)'
  )
    .bind(id, body.title, body.price, body.category, 'open', new Date().toISOString())
    .run();

  return Response.json({
    success: true,
    data: { id, ...body, status: 'open' },
  }, { status: 201 });
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
    'UPDATE jobs SET status = ? WHERE id = ?'
  )
    .bind(body.status, id)
    .run();

  return Response.json({
    success: true,
    data: { id, status: body.status },
  });
}
