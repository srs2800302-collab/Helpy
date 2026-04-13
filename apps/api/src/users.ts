import { requireAuth } from './auth-context';

type CreateUserBody = {
  role?: string;
  phone?: string;
  language?: string;
};

export async function createUser(request: Request, env: any) {
  let body: CreateUserBody;

  try {
    body = await request.json() as CreateUserBody;
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON' },
      { status: 400 }
    );
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

export async function getUserFull(id: string, request: Request, env: any) {
  const auth = await requireAuth(request, env);

  if (!auth.ok) {
    return auth.response;
  }

  if (auth.userId !== id && auth.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Forbidden' },
      { status: 403 }
    );
  }

  const user = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?1'
  )
    .bind(id)
    .first();

  if (!user) {
    return Response.json(
      { success: false, error: 'User not found' },
      { status: 404 }
    );
  }

  const clientProfile = await env.DB.prepare(
    'SELECT * FROM client_profiles WHERE user_id = ?1 LIMIT 1'
  )
    .bind(id)
    .first();

  const masterProfile = await env.DB.prepare(
    'SELECT * FROM master_profiles WHERE user_id = ?1 LIMIT 1'
  )
    .bind(id)
    .first();

  return Response.json({
    success: true,
    data: {
      user,
      client_profile: clientProfile || null,
      master_profile: masterProfile || null,
    },
  });
}
