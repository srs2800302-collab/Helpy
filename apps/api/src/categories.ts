const CATEGORIES = [
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

export async function getCategories() {
  return json({
    success: true,
    data: CATEGORIES.map((slug, index) => ({
      id: slug,
      slug,
      is_active: true,
      sort_order: index,
    })),
  });
}
