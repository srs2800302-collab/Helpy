type CreateClientProfileBody = {
  name?: string;
};

type CreateMasterProfileBody = {
  name?: string;
  category?: string;
  bio?: string;
};

export async function createClientProfile(userId: string, request: Request, env: any) {
  let body: CreateClientProfileBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON' },
      { status: 400 }
    );
  }

  if (!body.name) {
    return Response.json(
      { success: false, error: 'name required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    'INSERT INTO client_profiles (id, user_id, name, created_at) VALUES (?1, ?2, ?3, ?4)'
  )
    .bind(id, userId, body.name, new Date().toISOString())
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      user_id: userId,
      name: body.name,
    },
  });
}

export async function createMasterProfile(userId: string, request: Request, env: any) {
  let body: CreateMasterProfileBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON' },
      { status: 400 }
    );
  }

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
    data: {
      id,
      user_id: userId,
      name: body.name,
      category: body.category,
      bio: body.bio ?? null,
      is_verified: 0,
    },
  });
}
