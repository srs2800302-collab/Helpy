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

export function buildInitialTranslationsJson({
  text,
  sourceLanguage,
}: {
  text: string;
  sourceLanguage: string | null | undefined;
}) {
  const originalText = text.trim();
  const source = normalizeLanguage(sourceLanguage);
  return JSON.stringify(buildEmptyTranslations(originalText, source));
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
  const useAutoDetect =
    entityType === 'chat_message' || entityType === 'offer' || entityType === 'review';
  const source = useAutoDetect ? 'auto' : normalizeLanguage(sourceLanguage);

  await ensureTranslationTasksSchema(env);

  const translations: Record<SupportedLanguage, string> = useAutoDetect
    ? { ru: '', en: '', th: '' }
    : buildEmptyTranslations(originalText, source as SupportedLanguage);
  const now = new Date().toISOString();

  for (const target of SUPPORTED_LANGUAGES) {
    if (!useAutoDetect && target === source) continue;

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

async function translateWithGooglePublic({
  text,
  sourceLanguage,
  targetLanguage,
}: {
  text: string;
  sourceLanguage: string;
  targetLanguage: string;
}) {
  const url =
    `https://translate.googleapis.com/translate_a/single?client=gtx` +
    `&sl=${encodeURIComponent(sourceLanguage)}` +
    `&tl=${encodeURIComponent(targetLanguage)}` +
    `&dt=t&q=${encodeURIComponent(text)}`;

  const response = await fetch(url, { method: 'GET' });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Google public translate failed: ${response.status} ${errorText}`);
  }

  const payload = (await response.json()) as any;
  const segments = Array.isArray(payload?.[0]) ? payload[0] : [];

  return segments
    .map((segment: any) => segment?.[0]?.toString() ?? '')
    .join('')
    .trim();
}

export async function processPendingTranslationTasks({
  env,
  entityType,
  entityId,
  limit = 10,
}: {
  env: any;
  entityType?: string;
  entityId?: string;
  limit?: number;
}) {
  await ensureTranslationTasksSchema(env);

  const staleProcessingBefore = new Date(Date.now() - 5 * 60 * 1000).toISOString();
  await env.DB.prepare(`
    UPDATE translation_tasks
    SET status = 'pending',
        updated_at = ?1
    WHERE status = 'processing'
      AND updated_at < ?2
  `).bind(new Date().toISOString(), staleProcessingBefore).run();

  const where = entityType && entityId
    ? "WHERE status = 'pending' AND entity_type = ?1 AND entity_id = ?2"
    : "WHERE status = 'pending'";

  const query = `
    SELECT *
    FROM translation_tasks
    ${where}
    ORDER BY created_at ASC
    LIMIT ${Math.max(1, Math.min(limit, 100))}
  `;

  const tasksResult = entityType && entityId
    ? await env.DB.prepare(query).bind(entityType, entityId).all()
    : await env.DB.prepare(query).all();

  const tasks = tasksResult.results ?? [];
  const processed = [];
  const failed = [];
  const claimedTasks = [];

  for (const task of tasks) {
    const claim = await env.DB.prepare(`
      UPDATE translation_tasks
      SET status = 'processing',
          updated_at = ?1
      WHERE id = ?2
        AND status = 'pending'
    `).bind(new Date().toISOString(), task.id).run();

    if ((claim?.meta?.changes ?? 0) > 0) {
      claimedTasks.push(task);
    }
  }

  const translationResults = await Promise.all(
    claimedTasks.map(async (task: any) => {
      const entityTypeValue = String(task.entity_type);
      const fieldName = String(task.field_name);

      const table =
        entityTypeValue === 'job'
          ? 'jobs'
          : entityTypeValue === 'offer'
            ? 'offers'
            : entityTypeValue === 'chat_message'
              ? 'chat_messages'
              : entityTypeValue === 'review'
                ? 'reviews'
                : null;

      const column =
        entityTypeValue === 'job' && fieldName === 'title'
          ? 'title_translations_json'
          : entityTypeValue === 'job' && fieldName === 'description'
            ? 'description_translations_json'
            : entityTypeValue === 'job' && fieldName === 'address_text'
              ? 'address_translations_json'
              : entityTypeValue === 'offer' && fieldName === 'comment'
                ? 'comment_translations_json'
                : entityTypeValue === 'offer' && fieldName === 'message'
                  ? 'message_translations_json'
                  : entityTypeValue === 'chat_message' && fieldName === 'text'
                    ? 'text_translations_json'
                    : entityTypeValue === 'review' && fieldName === 'comment'
                      ? 'comment_translations_json'
                      : null;

      if (!table || !column) {
        return {
          task,
          translatedText: '',
          table,
          column,
          error: 'Unsupported translation target',
        };
      }

      try {
        const translatedText = await translateWithGooglePublic({
          text: String(task.original_text ?? ''),
          sourceLanguage: String(task.source_language),
          targetLanguage: String(task.target_language),
        });

        return {
          task,
          translatedText,
          table,
          column,
          error: translatedText ? null : 'Empty translation result',
        };
      } catch (error: any) {
        return {
          task,
          translatedText: '',
          table,
          column,
          error: error?.message ?? 'Unknown translation error',
        };
      }
    }),
  );

  for (const result of translationResults) {
    const task = result.task;

    try {
      if (result.error || !result.translatedText || !result.table || !result.column) {
        await env.DB.prepare(`
          UPDATE translation_tasks
          SET status = 'pending',
              updated_at = ?1
          WHERE id = ?2
            AND status = 'processing'
        `).bind(new Date().toISOString(), task.id).run();

        failed.push({ id: task.id, error: result.error ?? 'Unknown translation error' });
        continue;
      }

      const entity = await env.DB.prepare(`SELECT ${result.column} FROM ${result.table} WHERE id = ?1`)
        .bind(task.entity_id)
        .first();

      if (!entity) {
        await env.DB.prepare(`
          UPDATE translation_tasks
          SET status = 'pending',
              updated_at = ?1
          WHERE id = ?2
            AND status = 'processing'
        `).bind(new Date().toISOString(), task.id).run();

        failed.push({ id: task.id, error: 'Translation entity not found' });
        continue;
      }

      let translations: any = {};
      try {
        translations = JSON.parse(entity[result.column] ?? '{}');
      } catch (_) {
        translations = {};
      }

      translations[String(task.target_language)] = result.translatedText;

      await env.DB.prepare(`
        UPDATE translation_tasks
        SET translated_text = ?1,
            status = 'completed',
            updated_at = ?2
        WHERE id = ?3
      `).bind(result.translatedText, new Date().toISOString(), task.id).run();

      await env.DB.prepare(`UPDATE ${result.table} SET ${result.column} = ?1 WHERE id = ?2`)
        .bind(JSON.stringify(translations), task.entity_id)
        .run();

      processed.push({
        id: task.id,
        entity_id: task.entity_id,
        field_name: task.field_name,
        target_language: task.target_language,
      });
    } catch (error: any) {
      await env.DB.prepare(`
        UPDATE translation_tasks
        SET status = 'pending',
            updated_at = ?1
        WHERE id = ?2
          AND status = 'processing'
      `).bind(new Date().toISOString(), task.id).run();

      failed.push({ id: task.id, error: error?.message ?? 'Unknown translation error' });
    }
  }

  return {
    processed,
    failed,
    pending_checked: tasks.length,
  };
}
