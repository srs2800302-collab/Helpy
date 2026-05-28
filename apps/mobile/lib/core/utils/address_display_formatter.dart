class AddressDisplayFormatter {
  static String formatAddress(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';

    final parts = _splitAddressParts(raw);
    if (parts.isEmpty) return '';

    final postcode = parts.firstWhere(_isPostcode, orElse: () => '');
    final street = _selectStreet(parts);

    return [
      if (street.isNotEmpty) street,
      'Pattaya',
      if (postcode.isNotEmpty) postcode,
      'Thailand',
    ].join(', ');
  }

  static String formatAddressWithRoom(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';

    String room = '';
    final addressLines = <String>[];

    for (final sourceLine in raw.split('\n')) {
      final line = sourceLine.trim();
      if (line.isEmpty) continue;

      final separatorIndex = line.indexOf(':');
      final key = separatorIndex >= 0
          ? line.substring(0, separatorIndex).trim().toLowerCase()
          : '';
      final body =
          separatorIndex >= 0 ? line.substring(separatorIndex + 1).trim() : line;

      if (body.isEmpty || _isGpsKey(key)) continue;

      if (_isRoomKey(key)) {
        room = body;
        continue;
      }

      if (key.isEmpty || _isAddressKey(key)) {
        addressLines.add(body);
      }
    }

    final address = formatAddress(addressLines.join(', '));

    return [
      if (address.isNotEmpty) address,
      if (room.isNotEmpty) 'Room/unit: $room',
    ].join('\n');
  }

  static bool hasStrongAddress(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return false;

    final parts = _splitAddressParts(raw);
    if (parts.isEmpty) return false;

    final street = _selectStreet(parts);
    return street.isNotEmpty && _looksLikeStreet(street);
  }

  static bool hasUsableJobLocation({
    required String? addressText,
    required double? latitude,
    required double? longitude,
  }) {
    return latitude != null && longitude != null && hasStrongAddress(addressText);
  }

  static List<String> _splitAddressParts(String value) {
    final normalized = value
        .replaceAll('\n', ',')
        .replaceAll('ทัพพระยา', 'Thap Phraya')
        .replaceAll('พระตำหนัก', 'Pratumnak')
        .replaceAll('จอมเทียน', 'Jomtien')
        .replaceAll('เมืองพัทยา', 'Pattaya')
        .replaceAll('พัทยา', 'Pattaya')
        .replaceAll('ประเทศไทย', 'Thailand')
        .replaceAll('ชลบุรี', 'Chon Buri');

    return normalized
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  static String _selectStreet(List<String> parts) {
    final candidates = parts
        .where((part) => !_isGeoNoise(part))
        .map(_stripLeadingHouseNumber)
        .where((part) => part.isNotEmpty)
        .toList();

    final unique = <String>[];
    for (final candidate in candidates) {
      final key = _dedupeKey(candidate);
      if (!unique.any((existing) => _dedupeKey(existing) == key)) {
        unique.add(candidate);
      }
    }

    return unique.firstWhere(
      _looksLikeStreet,
      orElse: () => unique.isNotEmpty ? unique.first : '',
    );
  }

  static String _stripLeadingHouseNumber(String value) {
    return value
        .replaceFirst(RegExp(r'^(?:\d+[A-Za-z]?\s+){1,3}(?=[A-Za-z])'), '')
        .trim();
  }

  static String _dedupeKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _looksLikeStreet(String value) {
    final lower = value.toLowerCase();

    return lower.contains('soi') ||
        lower.contains('road') ||
        lower.contains('rd') ||
        lower.contains('street') ||
        lower.contains('thap phraya') ||
        lower.contains('pratumnak') ||
        lower.contains('phra tamnak') ||
        lower.contains('jomtien') ||
        RegExp(r'[A-Za-z].*\d|\d.*[A-Za-z]').hasMatch(value);
  }

  static bool _isGeoNoise(String value) {
    final lower = value.toLowerCase();

    return lower == 'thailand' ||
        lower == 'pattaya' ||
        lower == 'pattaya city' ||
        lower == 'muang pattaya' ||
        lower == 'mueang pattaya' ||
        lower.contains('chon buri') ||
        lower.contains('chonburi') ||
        lower.contains('bang lamung') ||
        lower.startsWith('amphoe ') ||
        lower.startsWith('amphur ') ||
        lower.startsWith('district ') ||
        _hasThaiText(value) ||
        _isPostcode(value);
  }

  static bool _isGpsKey(String key) {
    return key == 'gps' || key == 'гпс' || key == 'จีพีเอส';
  }

  static bool _isRoomKey(String key) {
    return key == 'room/unit' ||
        key == 'room / unit' ||
        key == 'комната' ||
        key == 'комната / юнит' ||
        key == 'ห้อง/ยูนิต' ||
        key == 'ห้อง / ยูนิต';
  }

  static bool _isAddressKey(String key) {
    return key == 'address' || key == 'адрес' || key == 'ที่อยู่';
  }

  static bool _isPostcode(String value) {
    return RegExp(r'^\d{5}$').hasMatch(value);
  }

  static bool _hasThaiText(String value) {
    return RegExp(r'[\u0E00-\u0E7F]').hasMatch(value);
  }
}
