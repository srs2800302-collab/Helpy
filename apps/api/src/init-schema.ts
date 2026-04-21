const FIXED_ADMIN_ID = '11111111-1111-1111-1111-111111111111';
const FIXED_ADMIN_PHONE = '+70000000001';
const FIXED_ADMIN_LANGUAGE = 'ru';

export async function ensureBaseSchema(env: any) {
  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      role TEXT NOT NULL,
      phone TEXT NOT NULL,
      language TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS client_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS master_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      category TEXT,
      bio TEXT,
      is_verified INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  `).run();

  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS jobs (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      price REAL NOT NULL DEFAULT 0,
      category TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT,
      client_user_id TEXT NOT NULL,
      description TEXT,
      address_text TEXT,
      title_original TEXT,
      description_original TEXT,
      source_language TEXT,
      title_translations_json TEXT,
      description_translations_json TEXT,
      budget_type TEXT,
      budget_from REAL,
      budget_to REAL,
      currency TEXT DEFAULT 'THB',
      selected_master_user_id TEXT,
      selected_master_name TEXT,
      selected_offer_id TEXT,
      selected_offer_price REAL
    )
  `).run();

  const columns = await env.DB.prepare('PRAGMA table_info(jobs)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['updated_at', 'ALTER TABLE jobs ADD COLUMN updated_at TEXT'],
    ['client_user_id', 'ALTER TABLE jobs ADD COLUMN client_user_id TEXT'],
    ['description', 'ALTER TABLE jobs ADD COLUMN description TEXT'],
    ['address_text', 'ALTER TABLE jobs ADD COLUMN address_text TEXT'],
    ['title_original', 'ALTER TABLE jobs ADD COLUMN title_original TEXT'],
    ['description_original', 'ALTER TABLE jobs ADD COLUMN description_original TEXT'],
    ['source_language', 'ALTER TABLE jobs ADD COLUMN source_language TEXT'],
    ['title_translations_json', 'ALTER TABLE jobs ADD COLUMN title_translations_json TEXT'],
    ['description_translations_json', 'ALTER TABLE jobs ADD COLUMN description_translations_json TEXT'],
    ['budget_type', 'ALTER TABLE jobs ADD COLUMN budget_type TEXT'],
    ['budget_from', 'ALTER TABLE jobs ADD COLUMN budget_from REAL'],
    ['budget_to', 'ALTER TABLE jobs ADD COLUMN budget_to REAL'],
    ['currency', "ALTER TABLE jobs ADD COLUMN currency TEXT DEFAULT 'THB'"],
    ['selected_master_user_id', 'ALTER TABLE jobs ADD COLUMN selected_master_user_id TEXT'],
    ['selected_master_name', 'ALTER TABLE jobs ADD COLUMN selected_master_name TEXT'],
    ['selected_offer_id', 'ALTER TABLE jobs ADD COLUMN selected_offer_id TEXT'],
    ['selected_offer_price', 'ALTER TABLE jobs ADD COLUMN selected_offer_price REAL'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }

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
