type Env = {
  DB: D1Database;
};

const MVP_CATEGORIES = [
  'cleaning',
  'handyman',
  'plumbing',
  'electrical',
  'locks',
  'aircon',
  'furniture_assembly',
] as const;

function json(data: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(data), {
    headers: { 'content-type': 'application/json' },
    ...init,
  });
}

async function ensureCategoriesSchema(env: Env) {
  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS service_categories (
      id TEXT PRIMARY KEY,
      slug TEXT NOT NULL UNIQUE,
      is_active INTEGER NOT NULL DEFAULT 1,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  `).run();

  const now = new Date().toISOString();

  for (const [index, slug] of MVP_CATEGORIES.entries()) {
    const existing = await env.DB.prepare(`
      SELECT id
      FROM service_categories
      WHERE slug = ?
      LIMIT 1
    `).bind(slug).first();

    if (!existing) {
      await env.DB.prepare(`
        INSERT INTO service_categories (
          id, slug, is_active, sort_order, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
      `).bind(
        crypto.randomUUID(),
        slug,
        1,
        index,
        now,
        now,
      ).run();
    } else {
      await env.DB.prepare(`
        UPDATE service_categories
        SET is_active = 1,
            sort_order = ?,
            updated_at = ?
        WHERE slug = ?
      `).bind(index, now, slug).run();
    }
  }
}

export async function getCategories(env: Env) {
  try {
    await ensureCategoriesSchema(env);

    const result = await env.DB.prepare(`
      SELECT id, slug, is_active, sort_order, created_at, updated_at
      FROM service_categories
      WHERE is_active = 1
      ORDER BY sort_order ASC, slug ASC
    `).all();

    return json({
      success: true,
      data: result.results ?? [],
    });
  } catch (error) {
    return json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: error instanceof Error ? error.message : 'Failed to load categories',
          details: null,
        },
      },
      { status: 500 },
    );
  }
}
