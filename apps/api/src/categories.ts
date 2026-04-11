type Env = {
  DB: D1Database;
};

function json(data: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(data), {
    headers: { 'content-type': 'application/json' },
    ...init,
  });
}

export async function getCategories(env: Env) {
  try {
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
