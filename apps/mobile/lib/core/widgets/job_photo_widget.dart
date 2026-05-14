import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class JobPhotoWidget extends StatelessWidget {
  const JobPhotoWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  Widget _error(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black12,
      alignment: Alignment.center,
      child: Text(AppLocalizations.of(context).t('failed_load_photo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image/')) {
      final commaIndex = url.indexOf(',');

      if (commaIndex > 0 && commaIndex + 1 < url.length) {
        try {
          final bytes = base64Decode(url.substring(commaIndex + 1));

          return Image.memory(
            Uint8List.fromList(bytes),
            fit: fit,
            errorBuilder: (_, __, ___) => _error(context),
          );
        } catch (_) {
          return _error(context);
        }
      }
    }

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => _error(context),
    );
  }
}
