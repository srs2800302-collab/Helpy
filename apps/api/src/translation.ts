const SUPPORTED_LANGUAGES = ['ru', 'en', 'th'] as const;

type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

function normalizeLanguage(value: unknown): SupportedLanguage | null {
  const lang = String(value ?? '').trim().toLowerCase();

  if (lang.startsWith('ru')) return 'ru';
  if (lang.startsWith('en')) return 'en';
  if (lang.startsWith('th')) return 'th';

  return null;
}

async function translateWithGoogle({
  text,
  sourceLanguage,
  targetLanguage,
  env,
}: {
  text: string;
  sourceLanguage: SupportedLanguage | null;
  targetLanguage: SupportedLanguage;
  env: any;
}) {
  const apiKey = env.GOOGLE_TRANSLATE_API_KEY;

  if (!apiKey) return '';

  const params = new URLSearchParams();
  params.set('q', text);
  params.set('target', targetLanguage);
  params.set('format', 'text');

  if (sourceLanguage) {
    params.set('source', sourceLanguage);
  }

  params.set('key', apiKey);

  const response = await fetch(
    `https://translation.googleapis.com/language/translate/v2?${params.toString()}`,
    { method: 'POST' },
  );

  if (!response.ok) {
    return '';
  }

  const payload = (await response.json()) as any;
  return payload?.data?.translations?.[0]?.translatedText?.toString().trim() ?? '';
}

export async function buildTranslationsJson({
  text,
  sourceLanguage,
  env,
}: {
  text: string;
  sourceLanguage: string | null | undefined;
  env: any;
}) {
  const originalText = text.trim();
  const source = normalizeLanguage(sourceLanguage);

  const entries: Record<SupportedLanguage, string> = {
    ru: '',
    en: '',
    th: '',
  };

  for (const target of SUPPORTED_LANGUAGES) {
    if (source === target) {
      entries[target] = originalText;
      continue;
    }

    entries[target] = await translateWithGoogle({
      text: originalText,
      sourceLanguage: source,
      targetLanguage: target,
      env,
    });
  }

  return JSON.stringify(entries);
}
