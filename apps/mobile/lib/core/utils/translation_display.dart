import 'dart:convert';

String translatedOrOriginal({
  required String? original,
  required String? translationsJson,
  required String locale,
}) {
  final rawOriginal = (original ?? '').trim();
  final raw = translationsJson?.trim();

  if (raw == null || raw.isEmpty) return rawOriginal;

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      final value = decoded[locale]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
  } catch (_) {
    return rawOriginal;
  }

  return rawOriginal;
}

bool hasRealTranslation({
  required String? original,
  required String? translated,
}) {
  final rawOriginal = (original ?? '').trim();
  final rawTranslated = (translated ?? '').trim();
  return rawTranslated.isNotEmpty && rawTranslated != rawOriginal;
}
