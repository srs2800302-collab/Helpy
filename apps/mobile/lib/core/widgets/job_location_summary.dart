import 'package:flutter/material.dart';

class JobLocationSummary extends StatelessWidget {
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final int maxAddressLines;

  const JobLocationSummary({
    super.key,
    required this.addressText,
    this.latitude,
    this.longitude,
    this.maxAddressLines = 2,
  });

  List<_LocationLine> _lines() {
    final raw = (addressText ?? '').trim();
    final result = <_LocationLine>[];

    for (final sourceLine in raw.split('\n')) {
      final line = sourceLine.trim();
      if (line.isEmpty) continue;

      final lower = line.toLowerCase();
      if (lower.startsWith('address:')) {
        final value = line.substring(line.indexOf(':') + 1).trim();
        if (value.isNotEmpty) {
          result.add(_LocationLine(Icons.location_on_outlined, value));
        }
      } else if (lower.startsWith('room/unit:')) {
        final value = line.substring(line.indexOf(':') + 1).trim();
        if (value.isNotEmpty) {
          result.add(_LocationLine(Icons.meeting_room_outlined, value));
        }
      } else if (lower.startsWith('gps:')) {
        final value = line.substring(line.indexOf(':') + 1).trim();
        if (value.isNotEmpty) {
          result.add(_LocationLine(Icons.my_location_outlined, value));
        }
      } else {
        result.add(_LocationLine(Icons.location_on_outlined, line));
      }
    }

    final hasGpsLine = result.any(
      (line) => line.icon == Icons.my_location_outlined,
    );
    if (!hasGpsLine && latitude != null && longitude != null) {
      result.add(
        _LocationLine(
          Icons.my_location_outlined,
          '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines();
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(line.icon, size: 17, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      line.text,
                      maxLines: line.icon == Icons.location_on_outlined
                          ? maxAddressLines
                          : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationLine {
  final IconData icon;
  final String text;

  const _LocationLine(this.icon, this.text);
}
