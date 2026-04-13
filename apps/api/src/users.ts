import { requireAuth } from './auth-context';

type CreateUserBody = {
  role?: string;
  phone?: string;
  language?: string;
};

const PUBLIC_ROLES = new Set(['client', 'master']);
const ALLOWED_LANGUAGES = new Set(['ru', 'en', 'th']);
const USER_SELECT =
  'SELECT id, role, phone, language, created_at FROM users WHERE id = ?1 LIMIT 1';

function jsonError(error: string, status: number) {
  return Response.json({ success: false, error }, { status });
}

function forbidden() {
  return jsonError('Forbidden', 403);
}

function sanitizeUser(row: any) {
  if (!row) return null;
  return {
    id: row.id,
    role: row.role,
    phone: row.phone,
    language: row.language,
    created_at: row.created_at ?? null,
  };
}

function sanitizeClientProfile(row: any) {
  if (!row) return null;
  return {
    id: row.id,
    user_id: row.user_id,
    name: row.name ?? null,
    created_at: row.created_at ?? null,
  };
}

function sanitizeMasterProfile(row: any) {
  if (!row) return null;
  return {
    id: row.id,
    user_id: row.user_id,
    name: row.name ?? null,
    category: row.category ?? null,
    bio: row.bio ?? null,
    is_verified: row.is_verified ?? 0,
    created_at: row.created_at ?? null,
  };
}

async function getUserRow(id: string, env: any) {
  return env.DB.prepare(USER_SELECT).bind(id).first();
}

export async function createUser(request: Request, env: any) {
  let body: CreateUserBody;

  try {
    body = await request.json() as CreateUserBody;
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  if (!body.role || !body.phone || !body.language) {
    return jsonError('role, phone, language required', 400);
  }

  if (!PUBLIC_ROLES.has(body.role)) {
    return jsonError('Invalid role', 400);
  }

  if (!ALLOWED_LANGUAGES.has(body.language)) {
    return jsonError('Invalid language', 400);
  }

  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();

  await env.DB.prepare(
    'INSERT INTO users (id, role, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5)'
  )
    .bind(id, body.role, body.phone, body.language, createdAt)
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      role: body.role,
      phone: body.phone,
      language: body.language,
      created_at: createdAt,
    },
  });
}

export async function getUser(id: string, request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.userId !== id && auth.role !== 'admin') {
    return forbidden();
  }

  const user = await getUserRow(id, env);
  if (!user) {
    return jsonError('User not found', 404);
  }

  return Response.json({
    success: true,
    data: sanitizeUser(user),
  });
}

export async function getUserFull(id: string, request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.userId !== id && auth.role !== 'admin') {
    return forbidden();
  }

  const user = await getUserRow(id, env);
  if (!user) {
    return jsonError('User not found', 404);
  }

  const clientProfile = await env.DB.prepare(
    `SELECT id, user_id, name, created_at
     FROM client_profiles
     WHERE user_id = ?1
     LIMIT 1`
  )
    .bind(id)
    .first();

  const masterProfile = await env.DB.prepare(
    `SELECT id, user_id, name, category, bio, is_verified, created_at
     FROM master_profiles
     WHERE user_id = ?1
     LIMIT 1`
  )
    .bind(id)
    .first();

  return Response.json({
    success: true,
    data: {
      user: sanitizeUser(user),
      client_profile: sanitizeClientProfile(clientProfile),
      master_profile: sanitizeMasterProfile(masterProfile),
    },
  });
}
