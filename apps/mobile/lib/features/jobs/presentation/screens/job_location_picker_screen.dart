import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/app_localizations.dart';

class JobLocationPickerResult {
  final double latitude;
  final double longitude;

  const JobLocationPickerResult({
    required this.latitude,
    required this.longitude,
  });
}

class JobLocationPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const JobLocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<JobLocationPickerScreen> createState() => _JobLocationPickerScreenState();
}

class _JobLocationPickerScreenState extends State<JobLocationPickerScreen> {
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLatitude, widget.initialLongitude);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('pick_location')),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 13,
                onTap: (_, point) {
                  setState(() {
                    _selectedPoint = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.helpy.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Lat: ${_selectedPoint.latitude.toStringAsFixed(6)}, '
                  'Lng: ${_selectedPoint.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        JobLocationPickerResult(
                          latitude: _selectedPoint.latitude,
                          longitude: _selectedPoint.longitude,
                        ),
                      );
                    },
                    child: Text(l10n.t('confirm_point')),
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
