import { fail } from './response';

export async function requireAuth(request: Request, env: any) {
  const userId = request.headers.get('x-user-id');

  if (!userId) {
    return {
      ok: false,
      response: fail('Missing x-user-id header', 401),
    };
  }

  const user = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?1 LIMIT 1'
  )
    .bind(userId)
    .first();

  if (!user) {
    return {
      ok: false,
      response: fail('User not found', 404),
    };
  }

  return {
    ok: true,
    userId: user.id,
    user,
    role: user.role,
  };
}

export function requireRequestUserId(request: Request) {
  const userId = request.headers.get('x-user-id');

  if (!userId) {
    return {
      ok: false,
      response: fail('Missing x-user-id header', 401),
    };
  }

  return {
    ok: true,
    userId,
  };
}
