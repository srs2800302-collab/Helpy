const SUPPORTED_LANGUAGES = ['ru', 'en', 'th'] as const;

type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

function normalizeLanguage(value: unknown): SupportedLanguage {
  const lang = String(value ?? '').trim().toLowerCase();

  if (lang.startsWith('en')) return 'en';
  if (lang.startsWith('th')) return 'th';
  return 'ru';
}

async function ensureTranslationTasksSchema(env: any) {
  await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS translation_tasks (
      id TEXT PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      field_name TEXT NOT NULL,
      source_language TEXT NOT NULL,
      target_language TEXT NOT NULL,
      original_text TEXT NOT NULL,
      translated_text TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      updated_at TEXT
    )
  `).run();
}

function buildEmptyTranslations(originalText: string, sourceLanguage: SupportedLanguage) {
  const entries: Record<SupportedLanguage, string> = {
    ru: '',
    en: '',
    th: '',
  };

  entries[sourceLanguage] = originalText;
  return entries;
}

export async function buildTranslationsJson({
  text,
  sourceLanguage,
  env,
  entityType,
  entityId,
  fieldName,
}: {
  text: string;
  sourceLanguage: string | null | undefined;
  env: any;
  entityType: string;
  entityId: string;
  fieldName: string;
}) {
  const originalText = text.trim();
  const source = normalizeLanguage(sourceLanguage);

  await ensureTranslationTasksSchema(env);

  const translations = buildEmptyTranslations(originalText, source);
  const now = new Date().toISOString();

  for (const target of SUPPORTED_LANGUAGES) {
    if (target === source) continue;

    await env.DB.prepare(`
      INSERT OR REPLACE INTO translation_tasks (
        id,
        entity_type,
        entity_id,
        field_name,
        source_language,
        target_language,
        original_text,
        translated_text,
        status,
        created_at,
        updated_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, NULL, 'pending', ?8, ?9)
    `).bind(
      `${entityType}:${entityId}:${fieldName}:${source}:${target}`,
      entityType,
      entityId,
      fieldName,
      source,
      target,
      originalText,
      now,
      now,
    ).run();
  }

  return JSON.stringify(translations);
}

export async function cleanupTranslationTasksForEntity({
  env,
  entityType,
  entityId,
}: {
  env: any;
  entityType: string;
  entityId: string;
}) {
  await ensureTranslationTasksSchema(env);

  await env.DB.prepare(
    'DELETE FROM translation_tasks WHERE entity_type = ?1 AND entity_id = ?2',
  ).bind(entityType, entityId).run();
}
