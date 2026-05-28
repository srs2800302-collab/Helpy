import 'package:flutter_test/flutter_test.dart';
import 'package:fixi_mobile/core/utils/address_display_formatter.dart';

void main() {
  group('AddressDisplayFormatter', () {
    test('removes duplicate street and building numbers', () {
      expect(
        AddressDisplayFormatter.formatAddress(
          '354 83 Thap Phraya 12, Thap Phraya 12, Pattaya, Chon Buri, 20150, Thailand',
        ),
        'Thap Phraya 12, Pattaya, 20150, Thailand',
      );
    });

    test('keeps readable soi area and removes province', () {
      expect(
        AddressDisplayFormatter.formatAddress(
          '473 Pratumnak Soi 6, Pratumnak Soi 6, Pattaya, Chon Buri, 20150, Thailand',
        ),
        'Pratumnak Soi 6, Pattaya, 20150, Thailand',
      );
    });

    test('keeps jomtien soi distinct from other soi numbers', () {
      expect(
        AddressDisplayFormatter.formatAddress(
          'Jomtien Soi 6, Pattaya, Chon Buri, 20150, Thailand',
        ),
        'Jomtien Soi 6, Pattaya, 20150, Thailand',
      );
    });

    test('keeps room as a separate line and removes gps', () {
      expect(
        AddressDisplayFormatter.formatAddressWithRoom(
          'Address: 354 83 Thap Phraya 12, Thap Phraya 12, Pattaya, Chon Buri, 20150, Thailand\nRoom/unit: 1205\nGPS: 12.9, 100.8',
        ),
        'Thap Phraya 12, Pattaya, 20150, Thailand\nRoom/unit: 1205',
      );
    });
  });
}
