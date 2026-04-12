import { ok } from './response';

const CATEGORIES = [
  'cleaning',
  'handyman',
  'plumbing',
  'electrical',
  'locks',
  'aircon',
  'furniture_assembly',
] as const;

export async function getCategories() {
  return ok(
    CATEGORIES.map((slug, index) => ({
      id: slug,
      slug,
      is_active: true,
      sort_order: index,
    }))
  );
}
