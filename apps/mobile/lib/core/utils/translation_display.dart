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

String addressWithoutGpsLine(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return '';

  return raw
      .split('\n')
      .where((line) {
        final normalized = line.trim().toLowerCase();
        return normalized.isNotEmpty &&
            !normalized.startsWith('gps:') &&
            !normalized.startsWith('gps ') &&
            !normalized.startsWith('гпс:') &&
            !normalized.startsWith('จีพีเอส:') &&
            !normalized.startsWith('จีพีเอส ');
      })
      .join('\n')
      .trim();
}
