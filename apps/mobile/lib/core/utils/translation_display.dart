import 'dart:convert';

String translatedOrOriginal({
  required String? original,
  required String? translationsJson,
  required String locale,
}) {
  final originalText = (original ?? '').trim();
  final raw = translationsJson?.trim();

  if (raw == null || raw.isEmpty) {
    return originalText;
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return originalText;

    final translatedText = (decoded[locale] ?? '').toString().trim();

    if (translatedText.isEmpty) {
      return originalText;
    }

    if (translatedText.toLowerCase() == originalText.toLowerCase()) {
      return originalText;
    }

    return translatedText;
  } catch (_) {
    return originalText;
  }
}

bool hasRealTranslation({
  required String? original,
  required String? translated,
}) {
  final originalText = (original ?? '').trim();
  final translatedText = (translated ?? '').trim();

  return translatedText.isNotEmpty &&
      translatedText.toLowerCase() != originalText.toLowerCase();
}
