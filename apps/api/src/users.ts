type CreateUserBody = {
  role?: string;
  phone?: string;
  language?: string;
};

export async function createUser(request: Request, env: any) {
  let body: CreateUserBody;

  try {
    body = await request.json();
  } catch {
    return Response.json({ success: false, error: 'Invalid JSON' }, { status: 400 });
  }

  if (!body.role || !body.phone || !body.language) {
    return Response.json(
      { success: false, error: 'role, phone, language required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO users (id, role, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5)'
  )
    .bind(id, body.role, body.phone, body.language, new Date().toISOString())
    .run();

  return Response.json({
    success: true,
    data: { id, ...body },
  });
}

export async function getUser(id: string, env: any) {
  const user = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?1'
  )
    .bind(id)
    .first();

  return Response.json({
    success: true,
    data: user || null,
  });
}
