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

String localizedAddressForDisplay({
  required String? original,
  required String? translationsJson,
  required String locale,
}) {
  final source = translatedOrOriginal(
    original: original,
    translationsJson: translationsJson,
    locale: 'en',
  );
  return compactAddressWithRoomForDisplay(source, locale: 'en');
}

String compactAddressWithRoomForDisplay(String? value, {String locale = 'en'}) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return '';

  String room = '';
  final addressLines = <String>[];

  for (final sourceLine in raw.split('\n')) {
    final line = sourceLine.trim();
    if (line.isEmpty) continue;

    final index = line.indexOf(':');
    final key = index >= 0 ? line.substring(0, index).trim().toLowerCase() : '';
    final body = index >= 0 ? line.substring(index + 1).trim() : line;

    final isGps = key == 'gps' || key == 'гпс' || key == 'จีพีเอส';
    final isRoom = key == 'room/unit' ||
        key == 'room / unit' ||
        key == 'комната' ||
        key == 'комната / юнит' ||
        key == 'ห้อง/ยูนิต' ||
        key == 'ห้อง / ยูนิต';

    if (isGps || body.isEmpty) continue;

    if (isRoom) {
      room = body;
      continue;
    }

    if (key.isEmpty || key == 'address' || key == 'адрес' || key == 'ที่อยู่') {
      addressLines.add(body);
    }
  }

  final compactAddress = compactAddressForDisplay(addressLines.join(', '), locale: locale);
  return [
    if (compactAddress.isNotEmpty) compactAddress,
    if (room.isNotEmpty) 'Room/unit: $room',
  ].join('\n');
}

String compactAddressForDisplay(String? value, {String locale = 'en'}) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) return '';

  final normalizedRaw = raw
      .replaceAll('ประเทศไทย', 'ประเทศไทย,')
      .replaceAll('พัทยา', 'พัทยา,')
      .replaceAll('ชลบุรี', 'ชลบุรี,');

  final addressParts = normalizedRaw
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (addressParts.isEmpty) return '';

  final hasThailand = addressParts.any(
    (part) => part.toLowerCase() == 'thailand' || part == 'ประเทศไทย',
  );
  final hasPattaya = addressParts.any(
    (part) => part.toLowerCase().contains('pattaya') || part.contains('พัทยา'),
  );
  final hasChonBuri = addressParts.any((part) {
    final lower = part.toLowerCase();
    return lower.contains('chon buri') || lower.contains('chonburi') || part.contains('ชลบุรี');
  });

  bool isThaiPart(String part) => RegExp(r'[\u0E00-\u0E7F]').hasMatch(part);

  bool isPostcodePart(String part) => RegExp(r'^\d{5}$').hasMatch(part);

  bool isKnownGeoPart(String part) {
    final lower = part.toLowerCase();
    return lower.contains('thailand') ||
        lower.contains('pattaya') ||
        lower.contains('chon buri') ||
        lower.contains('chonburi') ||
        isPostcodePart(part) ||
        isThaiPart(part);
  }

  final detailParts = addressParts.where((part) => !isKnownGeoPart(part)).toList();
  final area = detailParts.length >= 2 ? detailParts[0] : '';
  final street = detailParts.length >= 2
      ? detailParts[1]
      : detailParts.isNotEmpty
          ? detailParts[0]
          : '';

  final postcode = addressParts.firstWhere(
    isPostcodePart,
    orElse: () => '',
  );

  final shouldAssumeThailand = hasThailand || hasPattaya || hasChonBuri;
  final country = shouldAssumeThailand ? 'Thailand' : '';
  final city = hasPattaya ? 'Pattaya' : '';
  final province = hasChonBuri ? 'Chon Buri' : '';

  final compact = [
    area,
    street,
    city,
    province,
    postcode,
    country,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  return compact.isNotEmpty ? compact : addressParts.join(', ');
}
