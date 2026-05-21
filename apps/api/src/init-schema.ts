const FIXED_ADMIN_ID = '11111111-1111-1111-1111-111111111111';
const FIXED_ADMIN_PHONE = '+70000000001';
const FIXED_ADMIN_LANGUAGE = 'ru';

export async function ensureBaseSchema(env: any) {
  const admin = await env.DB.prepare(
    'SELECT id FROM users WHERE id = ?1 LIMIT 1'
  )
    .bind(FIXED_ADMIN_ID)
    .first();

  if (!admin) {
    await env.DB.prepare(
      'INSERT INTO users (id, role, phone, language, created_at) VALUES (?1, ?2, ?3, ?4, ?5)'
    )
      .bind(
        FIXED_ADMIN_ID,
        'admin',
        FIXED_ADMIN_PHONE,
        FIXED_ADMIN_LANGUAGE,
        new Date().toISOString(),
      )
      .run();
  }
}
