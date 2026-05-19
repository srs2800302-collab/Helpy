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

export function detectLanguageFromText(text: string): SupportedLanguage | null {
  const raw = text.trim();
  if (!raw) return null;
  if (/[\u0E00-\u0E7F]/.test(raw)) return 'th';
  if (/[\u0400-\u04FF]/.test(raw)) return 'ru';
  if (/[A-Za-z]/.test(raw)) return 'en';
  return null;
}

export function buildInitialTranslationsJson({
  text,
  sourceLanguage,
}: {
  text: string;
  sourceLanguage: string | null | undefined;
}) {
  const originalText = text.trim();
  const source = detectLanguageFromText(originalText) ?? normalizeLanguage(sourceLanguage);
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
    entityType === 'job' ||
    entityType === 'chat_message' ||
    entityType === 'offer' ||
    entityType === 'review';
  const source = useAutoDetect ? 'auto' : normalizeLanguage(sourceLanguage);

  await ensureTranslationTasksSchema(env);

  const translations: Record<SupportedLanguage, string> = useAutoDetect
    ? { ru: '', en: '', th: '' }
    : buildEmptyTranslations(originalText, source as SupportedLanguage);
  const now = new Date().toISOString();

  for (const target of SUPPORTED_LANGUAGES) {
    if (!useAutoDetect && target === source) continue;

    const taskId = `${entityType}:${entityId}:${fieldName}:${source}:${target}`;

    const existingTask = await env.DB.prepare(
      'SELECT original_text FROM translation_tasks WHERE id = ?1 LIMIT 1'
    ).bind(taskId).first();

    if (!existingTask) {
      await env.DB.prepare(`
        INSERT INTO translation_tasks (
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
        taskId,
        entityType,
        entityId,
        fieldName,
        source,
        target,
        originalText,
        now,
        now,
      ).run();

      continue;
    }

    if (String(existingTask.original_text ?? '') !== originalText) {
      await env.DB.prepare(`
        UPDATE translation_tasks
        SET original_text = ?1,
            translated_text = NULL,
            status = 'pending',
            updated_at = ?2
        WHERE id = ?3
      `).bind(
        originalText,
        now,
        taskId,
      ).run();
    }
  }

  return JSON.stringify(translations);
}

export function deferTranslations({
  env,
  entityType,
  entityId,
  sourceLanguage,
  fields,
  limit = 10,
}: {
  env: any;
  entityType: string;
  entityId: string;
  sourceLanguage: string | null | undefined;
  fields: Array<{ fieldName: string; text: string | null | undefined }>;
  limit?: number;
}) {
  return (async () => {
    for (const field of fields) {
      const text = field.text?.trim();
      if (!text) continue;

      await buildTranslationsJson({
        text,
        sourceLanguage,
        env,
        entityType,
        entityId,
        fieldName: field.fieldName,
      });
    }

    await processPendingTranslationTasks({
      env,
      entityType,
      entityId,
      limit,
    });
  })().catch(() => undefined);
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

function isValidTranslationForTargetLanguage({
  text,
  targetLanguage,
}: {
  text: string;
  targetLanguage: string;
}) {
  const raw = text.trim();
  if (!raw) return false;

  const hasThai = /[\u0E00-\u0E7F]/.test(raw);
  const hasCyrillic = /[\u0400-\u04FF]/.test(raw);
  const hasLatin = /[A-Za-z]/.test(raw);

  switch (targetLanguage) {
    case 'th':
      return hasThai && !hasCyrillic && !hasLatin;
    case 'en':
      return hasLatin && !hasCyrillic && !hasThai;
    case 'ru':
      return hasCyrillic && !hasThai;
    default:
      return true;
  }
}

function applyTranslationFallbacks({
  text,
  targetLanguage,
}: {
  text: string;
  targetLanguage: string;
}) {
  let normalized = text.trim();

  if (targetLanguage === 'th') {
    const replacements: Array<[RegExp, string]> = [
      [/\bfaucet\b/gi, 'ก๊อกน้ำ'],
      [/\bsockets?\b/gi, 'เต้ารับ'],
      [/\bplugs?\b/gi, 'ปลั๊ก'],
      [/\boutlets?\b/gi, 'เต้ารับ'],
    ];

    for (const [pattern, replacement] of replacements) {
      normalized = normalized.replace(pattern, replacement);
    }
  }

  return normalized.trim();
}

function looksLikeAddressText(text: string) {
  const raw = text.trim();
  return /Thailand|Pattaya|Chon Buri|Bang Lamung|Room\/unit|GPS/i.test(raw);
}

function localMvpTranslate({
  text,
  targetLanguage,
}: {
  text: string;
  targetLanguage: string;
}) {
  const raw = text.trim();
  const normalized = raw.toLowerCase();
  if (!raw) return '';
  if (looksLikeAddressText(raw)) return raw;

  const dictionary: Record<string, Record<string, string>> = {
    'убрать номер': { ru: 'убрать номер', en: 'clean room', th: 'ทำความสะอาดห้อง' },
    'с балконом': { ru: 'с балконом', en: 'with balcony', th: 'มีระเบียง' },
    'заменить розетки': { ru: 'заменить розетки', en: 'replace sockets', th: 'เปลี่ยนปลั๊กไฟ' },
    'заменить кран': { ru: 'заменить кран', en: 'replace faucet', th: 'เปลี่ยนก๊อกน้ำ' },
    'кондиционер не холодит': { ru: 'кондиционер не холодит', en: 'air conditioner is not cooling', th: 'แอร์ไม่เย็น' },
    'собрать шкаф': { ru: 'собрать шкаф', en: 'assemble wardrobe', th: 'ประกอบตู้เสื้อผ้า' },
    'починить замок': { ru: 'починить замок', en: 'fix lock', th: 'ซ่อมกุญแจ' },
  };

  const exact = dictionary[normalized]?.[targetLanguage];
  if (exact) return exact;
  if (targetLanguage === 'ru' && /[\u0400-\u04FF]/.test(raw)) return raw;

  return '';
}

async function translateWithProvider({
  text,
  sourceLanguage,
  targetLanguage,
  env,
}: {
  text: string;
  sourceLanguage: string;
  targetLanguage: string;
  env: any;
}) {
  const local = localMvpTranslate({ text, targetLanguage });
  if (local) return local;

  const apiKey = String(env?.TYPHOON_API_KEY ?? '').trim();
  const baseUrl = String(env?.TYPHOON_API_BASE_URL ?? 'https://api.opentyphoon.ai/v1').trim();
  const model = String(env?.TYPHOON_MODEL ?? 'typhoon2-7b-instruct').trim();

  if (!apiKey) return localMvpTranslate({ text, targetLanguage });

  try {
    const response = await fetch(`${baseUrl.replace(/\/$/, '')}/chat/completions`, {
      method: 'POST',
      headers: {
        'authorization': `Bearer ${apiKey}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model,
        temperature: 0,
        max_tokens: 80,
        messages: [
          {
            role: 'system',
            content:
              'You are a translation engine for a home-services marketplace in Thailand. Translate only the user text. Return plain text only. No quotes, no explanations.',
          },
          {
            role: 'user',
            content:
              `Translate from ${sourceLanguage === 'auto' ? 'auto-detected language' : sourceLanguage} to ${targetLanguage}: ${text}`,
          },
        ],
      }),
    });

    if (!response.ok) return localMvpTranslate({ text, targetLanguage });

    const payload = (await response.json()) as any;
    const translated = String(payload?.choices?.[0]?.message?.content ?? '').trim();

    return translated || localMvpTranslate({ text, targetLanguage });
  } catch (_) {
    return localMvpTranslate({ text, targetLanguage });
  }
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
        const rawTranslatedText = await translateWithProvider({
          text: String(task.original_text ?? ''),
          sourceLanguage: String(task.source_language),
          targetLanguage: String(task.target_language),
          env,
        });
        const translatedText = applyTranslationFallbacks({
          text: rawTranslatedText,
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
        failed.push({
          id: task.id,
          error: `Invalid translations JSON in ${result.table}.${result.column}`,
        });

        await env.DB.prepare(`
          UPDATE translation_tasks
          SET status = 'pending',
              updated_at = ?1
          WHERE id = ?2
            AND status = 'processing'
        `).bind(
          new Date().toISOString(),
          task.id,
        ).run();

        continue;
      }

      if (
        String(task.field_name) !== 'address_text' &&
        !isValidTranslationForTargetLanguage({
          text: result.translatedText,
          targetLanguage: String(task.target_language),
        })
      ) {
        await env.DB.prepare(`
          UPDATE translation_tasks
          SET status = 'pending',
              updated_at = ?1
          WHERE id = ?2
            AND status = 'processing'
        `).bind(new Date().toISOString(), task.id).run();

        failed.push({
          id: task.id,
          error: `Invalid translation script for ${task.target_language}`,
        });
        continue;
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
