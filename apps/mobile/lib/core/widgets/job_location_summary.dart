import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';

class JobLocationSummary extends StatelessWidget {
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final int maxAddressLines;
  final bool showCopyForGps;

  const JobLocationSummary({
    super.key,
    required this.addressText,
    this.latitude,
    this.longitude,
    this.maxAddressLines = 2,
    this.showCopyForGps = false,
  });

  bool get _hasGps => latitude != null && longitude != null;

  String get _gpsText =>
      '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';

  bool _isRoomLine(String lower) {
    return lower.startsWith('room/unit:') ||
        lower.startsWith('room / unit:') ||
        lower.startsWith('комната:') ||
        lower.startsWith('комната / юнит:') ||
        lower.startsWith('ห้อง/ยูนิต:') ||
        lower.startsWith('ห้อง / ยูนิต:');
  }

  List<_LocationLine> _lines() {
    final raw = (addressText ?? '').trim();
    final result = <_LocationLine>[];

    for (final sourceLine in raw.split('\n')) {
      final line = sourceLine.trim();
      if (line.isEmpty) continue;

      final lower = line.toLowerCase();
      final separatorIndex = line.indexOf(':');

      if (lower.startsWith('gps:') ||
          lower.startsWith('gps ') ||
          lower.startsWith('гпс:') ||
          lower.startsWith('จีพีเอส:')) {
        if (!_hasGps && separatorIndex >= 0) {
          final value = line.substring(separatorIndex + 1).trim();
          if (value.isNotEmpty) {
            result.add(
              _LocationLine(
                Icons.my_location_outlined,
                value,
                isGps: true,
              ),
            );
          }
        }
        continue;
      }

      if (lower.startsWith('address:') && separatorIndex >= 0) {
        final value = line.substring(separatorIndex + 1).trim();
        if (value.isNotEmpty) {
          result.add(
            _LocationLine(
              Icons.location_on_outlined,
              value,
              isAddress: true,
            ),
          );
        }
        continue;
      }

      if (_isRoomLine(lower) && separatorIndex >= 0) {
        final value = line.substring(separatorIndex + 1).trim();
        if (value.isNotEmpty) {
          result.add(
            _LocationLine(
              Icons.apartment_outlined,
              value,
              isRoom: true,
            ),
          );
        }
        continue;
      }

      result.add(
        _LocationLine(
          Icons.location_on_outlined,
          line,
          isAddress: true,
        ),
      );
    }

    if (_hasGps) {
      result.add(
        _LocationLine(
          Icons.my_location_outlined,
          _gpsText,
          isGps: true,
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = _lines();
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(lines[i].icon, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lines[i].isRoom
                        ? '${l10n.t('room_unit_label')}: ${lines[i].text}'
                        : lines[i].text,
                    maxLines: lines[i].isAddress ? maxAddressLines : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ),
                if (showCopyForGps && lines[i].isGps) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: lines[i].text),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.t('copied'))),
                        );
                      }
                    },
                    child: Icon(
                      Icons.copy,
                      size: 18,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationLine {
  final IconData icon;
  final String text;
  final bool isAddress;
  final bool isRoom;
  final bool isGps;

  const _LocationLine(
    this.icon,
    this.text, {
    this.isAddress = false,
    this.isRoom = false,
    this.isGps = false,
  });
}
