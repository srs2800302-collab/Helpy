const OTP_CODE = '123456';

function jsonError(error: string, status: number) {
  return Response.json({ success: false, error }, { status });
}

function makeTokens(userId: string) {
  return {
    accessToken: userId,
    refreshToken: userId,
  };
}

function sanitizeUser(row: any) {
  return {
    id: row.id,
    phone: row.phone,
    role: row.role,
    language: row.language,
    created_at: row.created_at ?? null,
  };
}

async function findOrCreateUser(phone: string, env: any) {
  const existing = await env.DB.prepare(
    'SELECT id, role, phone, language, created_at FROM users WHERE phone = ?1 LIMIT 1'
  ).bind(phone).first();

  if (existing) return existing;

  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();

  await env.DB.prepare(
    'INSERT INTO users (id, role, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5)'
  ).bind(id, 'client', phone, 'ru', createdAt).run();

  return {
    id,
    role: 'client',
    phone,
    language: 'ru',
    created_at: createdAt,
  };
}

export async function requestOtp(request: Request, env: any) {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  const phone = body.phone?.toString().trim();
  if (!phone) return jsonError('phone is required', 400);

  return Response.json({
    success: true,
    data: { phone, otp: OTP_CODE },
  });
}

export async function verifyOtp(request: Request, env: any) {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  const phone = body.phone?.toString().trim();
  const code = body.code?.toString().trim();

  if (!phone || !code) return jsonError('phone and code are required', 400);
  if (code !== OTP_CODE) return jsonError('Invalid OTP code', 400);

  const user = await findOrCreateUser(phone, env);

  return Response.json({
    success: true,
    data: {
      user: sanitizeUser(user),
      tokens: makeTokens(user.id),
    },
  });
}

export async function getMe(request: Request, env: any) {
  const auth = request.headers.get('Authorization') ?? '';
  const userId = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';

  if (!userId) return jsonError('Missing Authorization header', 401);

  const user = await env.DB.prepare(
    'SELECT id, role, phone, language, created_at FROM users WHERE id = ?1 LIMIT 1'
  ).bind(userId).first();

  if (!user) return jsonError('User not found', 404);

  return Response.json({
    success: true,
    data: {
      user: sanitizeUser(user),
      tokens: makeTokens(user.id),
    },
  });
}

export async function refresh(request: Request, env: any) {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  const userId = body.refreshToken?.toString().trim();
  if (!userId) return jsonError('refreshToken is required', 400);

  return getMe(
    new Request(request.url, {
      headers: { Authorization: `Bearer ${userId}` },
    }),
    env,
  );
}

export async function selectMyRole(request: Request, env: any) {
  const auth = request.headers.get('Authorization') ?? '';
  const userId = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';

  if (!userId) return jsonError('Missing Authorization header', 401);

  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  const role = body.role?.toString().trim();
  if (!['client', 'master', 'admin'].includes(role)) {
    return jsonError('Invalid role', 400);
  }

  await env.DB.prepare(
    'UPDATE users SET role = ?1 WHERE id = ?2'
  ).bind(role, userId).run();

  const user = await env.DB.prepare(
    'SELECT id, role, phone, language, created_at FROM users WHERE id = ?1 LIMIT 1'
  ).bind(userId).first();

  return Response.json({
    success: true,
    data: {
      user: sanitizeUser(user),
      tokens: makeTokens(userId),
    },
  });
}
