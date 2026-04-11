export async function createClientProfile(userId: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.name) {
    return Response.json({ success: false, error: 'name required' }, { status: 400 });
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO client_profiles (id, user_id, name, created_at) VALUES (?1, ?2, ?3, ?4)'
  )
    .bind(id, userId, body.name, new Date().toISOString())
    .run();

  return Response.json({ success: true, data: { id, user_id: userId, name: body.name } });
}

export async function createMasterProfile(userId: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.name || !body.category) {
    return Response.json(
      { success: false, error: 'name and category required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO master_profiles (id, user_id, name, category, bio, is_verified, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)'
  )
    .bind(
      id,
      userId,
      body.name,
      body.category,
      body.bio ?? null,
      0,
      new Date().toISOString()
    )
    .run();

  return Response.json({
    success: true,
    data: { id, user_id: userId, ...body, is_verified: 0 },
  });
}
