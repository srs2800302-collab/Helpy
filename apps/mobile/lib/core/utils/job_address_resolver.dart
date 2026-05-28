import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';

import 'address_display_formatter.dart';

class JobAddressResolver {
  JobAddressResolver({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                headers: const {'User-Agent': 'Helpy MVP Android'},
                responseType: ResponseType.plain,
              ),
            );

  final Dio _dio;

  Future<String> resolve({
    required double latitude,
    required double longitude,
  }) async {
    final googleAddress = await _reverseGeocodeWithGoogle(
      latitude: latitude,
      longitude: longitude,
    );

    if (AddressDisplayFormatter.hasStrongAddress(googleAddress)) {
      return AddressDisplayFormatter.formatAddress(googleAddress);
    }

    final osmAddress = await _reverseGeocodeWithOsm(
      latitude: latitude,
      longitude: longitude,
    );

    if (AddressDisplayFormatter.hasStrongAddress(osmAddress)) {
      return AddressDisplayFormatter.formatAddress(osmAddress);
    }

    return '';
  }

  Future<String> _reverseGeocodeWithGoogle({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await setLocaleIdentifier('en_US');
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return '';

      final candidates = placemarks
          .map(_googlePlacemarkAddress)
          .where((address) => address.isNotEmpty)
          .toList();

      candidates.sort((a, b) => _addressScore(b).compareTo(_addressScore(a)));
      return candidates.isEmpty ? '' : candidates.first;
    } catch (_) {
      return '';
    }
  }

  String _googlePlacemarkAddress(Placemark placemark) {
    return _uniqueReadableAddressParts([
      placemark.street,
      placemark.thoroughfare,
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ]).join(', ');
  }

  int _addressScore(String value) {
    final lower = value.toLowerCase();
    var score = 0;

    if (AddressDisplayFormatter.hasStrongAddress(value)) score += 100;
    if (RegExp(r'\d').hasMatch(value)) score += 20;
    if (lower.contains('soi')) score += 20;
    if (lower.contains('road') || lower.contains('rd')) score += 15;
    if (lower.contains('thap phraya')) score += 20;
    if (lower.contains('phra tamnak') || lower.contains('pratumnak')) {
      score += 20;
    }
    if (lower.contains('jomtien')) score += 20;
    if (lower.contains('pattaya')) score += 10;
    if (lower.contains('bang lamung')) score -= 5;
    if (lower.contains('chon buri') || lower.contains('chonburi')) score -= 5;

    return score;
  }

  Future<String> _reverseGeocodeWithOsm({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<String>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      final decoded = jsonDecode(response.data ?? '{}');
      final address = decoded is Map ? decoded['address'] : null;
      if (address is! Map) return '';

      return _uniqueReadableAddressParts([
        address['road']?.toString(),
        address['pedestrian']?.toString(),
        address['residential']?.toString(),
        address['neighbourhood']?.toString(),
        address['suburb']?.toString(),
        address['city_district']?.toString(),
        address['city']?.toString(),
        address['town']?.toString(),
        address['state']?.toString(),
      ]).join(', ');
    } catch (_) {
      return '';
    }
  }

  List<String> _uniqueReadableAddressParts(List<String?> values) {
    final seen = <String>{};
    final result = <String>[];

    for (final value in values) {
      final part = _readableAddressPart(value);
      if (part.isEmpty) continue;

      final key = part.toLowerCase();
      if (seen.add(key)) {
        result.add(part);
      }
    }

    return result;
  }

  String _readableAddressPart(String? value) {
    final text = (value ?? '').trim();
    return _isReadableAddressPart(text) ? text : '';
  }

  bool _isReadableAddressPart(String value) {
    final text = value.trim();
    if (text.isEmpty) return false;
    if (RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(text)) return false;
    if (RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$').hasMatch(text)) {
      return false;
    }
    if (RegExp(r'[\u0E00-\u0E7F]').hasMatch(text)) return false;
    return true;
  }
}
