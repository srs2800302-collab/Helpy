const ROLE_SWITCHER_EMAILS = new Set(['tester@fixi.dev']);

function jsonError(error: string, status: number) {
  return Response.json({ success: false, error }, { status });
}

function makeTokens(userId: string) {
  return {
    accessToken: userId,
    refreshToken: userId,
  };
}

function displayEmail(email: string) {
  return email.replace(/:master$/, '');
}

function sanitizeUser(row: any) {
  return {
    id: row.id,
    email: displayEmail(String(row.email ?? '')),
    role: row.role,
    language: row.language,
    created_at: row.created_at ?? null,
  };
}

type GoogleTokenInfo = {
  aud: string;
  sub: string;
  email?: string;
  email_verified?: string;
  exp: string;
};

async function verifyGoogleIdToken(idToken: string, env: any): Promise<GoogleTokenInfo> {
  const response = await fetch(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`,
  );

  if (!response.ok) {
    throw new Error('Invalid Google ID token');
  }

  const info = (await response.json()) as GoogleTokenInfo;

  if (!env.GOOGLE_OAUTH_CLIENT_ID || info.aud !== env.GOOGLE_OAUTH_CLIENT_ID) {
    throw new Error('Google ID token was issued for a different client');
  }

  if (info.email_verified !== 'true') {
    throw new Error('Google account email is not verified');
  }

  return info;
}

async function findOrCreateUserByGoogle(sub: string, email: string, env: any) {
  const existing = await env.DB.prepare(
    'SELECT id, role, email, language, created_at FROM users WHERE google_sub = ?1 LIMIT 1'
  ).bind(sub).first();

  if (existing) return existing;

  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();

  await env.DB.prepare(
    'INSERT INTO users (id, role, google_sub, email, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)'
  ).bind(id, 'client', sub, email, `google:${sub}`, 'ru', createdAt).run();

  return {
    id,
    role: 'client',
    email,
    language: 'ru',
    created_at: createdAt,
  };
}

export async function signInWithGoogle(request: Request, env: any) {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return jsonError('Invalid JSON', 400);
  }

  const idToken = body.id_token?.toString().trim();
  if (!idToken) return jsonError('id_token is required', 400);

  let info: GoogleTokenInfo;
  try {
    info = await verifyGoogleIdToken(idToken, env);
  } catch (e) {
    return jsonError(e instanceof Error ? e.message : 'Invalid Google ID token', 401);
  }

  const email = info.email?.toLowerCase().trim();
  if (!email) return jsonError('Google account has no email', 400);

  const user = await findOrCreateUserByGoogle(info.sub, email, env);

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
    'SELECT id, role, email, language, created_at FROM users WHERE id = ?1 LIMIT 1'
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
  const currentUserId = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';

  if (!currentUserId) return jsonError('Missing Authorization header', 401);

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

  const currentUser = await env.DB.prepare(
    'SELECT id, role, email, language, created_at FROM users WHERE id = ?1 LIMIT 1'
  ).bind(currentUserId).first();

  if (!currentUser) return jsonError('User not found', 404);

  const baseEmail = String(currentUser.email ?? '').replace(/:master$/, '');

  if (!ROLE_SWITCHER_EMAILS.has(baseEmail)) {
    return jsonError('Role switching is not allowed for this account', 403);
  }

  const now = new Date().toISOString();
  const targetEmail = role === 'master' ? `${baseEmail}:master` : baseEmail;

  let user = await env.DB.prepare(
    'SELECT id, role, email, language, created_at FROM users WHERE email = ?1 LIMIT 1'
  ).bind(targetEmail).first();

  if (!user) {
    const id = crypto.randomUUID();

    await env.DB.prepare(
      'INSERT INTO users (id, role, email, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6)'
    ).bind(id, role, targetEmail, `email:${targetEmail}`, currentUser.language ?? 'ru', now).run();

    user = {
      id,
      role,
      email: targetEmail,
      language: currentUser.language ?? 'ru',
      created_at: now,
    };
  } else if (user.role !== role) {
    await env.DB.prepare(
      'UPDATE users SET role = ?1 WHERE id = ?2'
    ).bind(role, user.id).run();

    user = {
      ...user,
      role,
    };
  }

  if (role === 'master') {
    await env.DB.prepare(
      `INSERT OR IGNORE INTO master_profiles (
        id,
        user_id,
        name,
        category,
        bio,
        is_verified,
        has_billing_method,
        billing_status,
        cash_jobs_enabled,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`
    ).bind(
      crypto.randomUUID(),
      user.id,
      'Test Master',
      'cleaning',
      'Test master profile',
      0,
      0,
      'missing',
      0,
      now,
    ).run();
  }

  return Response.json({
    success: true,
    data: {
      user: sanitizeUser(user),
      tokens: makeTokens(user.id),
    },
  });
}
