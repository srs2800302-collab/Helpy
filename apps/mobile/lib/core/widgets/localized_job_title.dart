import 'package:flutter/material.dart';

import '../utils/translation_display.dart';

class LocalizedJobTitle extends StatelessWidget {
  final String originalTitle;
  final String displayTitle;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final int maxLines;
  final double spacing;

  const LocalizedJobTitle({
    super.key,
    required this.originalTitle,
    required this.displayTitle,
    this.primaryStyle,
    this.secondaryStyle,
    this.maxLines = 2,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final candidate = displayTitle.trim();

    final hasValidTranslation = hasRealTranslation(
          original: originalTitle,
          translated: candidate,
        ) &&
        _isValidTitleForLocale(candidate, locale);

    final primary = hasValidTranslation ? candidate : originalTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: primaryStyle,
        ),
        if (hasValidTranslation) ...[
          SizedBox(height: spacing),
          Text(
            originalTitle,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: secondaryStyle,
          ),
        ],
      ],
    );
  }
}

bool _isValidTitleForLocale(String value, String locale) {
  final raw = value.trim();
  if (raw.isEmpty) return false;

  final hasThai = RegExp(r'[\u0E00-\u0E7F]').hasMatch(raw);
  final hasCyrillic = RegExp(r'[\u0400-\u04FF]').hasMatch(raw);
  final hasLatin = RegExp(r'[A-Za-z]').hasMatch(raw);

  switch (locale) {
    case 'th':
      return hasThai && !hasCyrillic && !hasLatin;

    case 'en':
      return hasLatin && !hasCyrillic && !hasThai;

    case 'ru':
    default:
      if (!hasCyrillic || hasThai) return false;

      if (!hasLatin) {
        return true;
      }

      return _latinTokensAreAllowedInRussianTitle(raw);
  }
}

bool _latinTokensAreAllowedInRussianTitle(String value) {
  final tokens = RegExp(
    r'[A-Za-z][A-Za-z0-9]*(?:-[A-Za-z0-9]+)*',
  ).allMatches(value).map((m) => m.group(0) ?? '');

  const allowed = {
    'AC',
    'TV',
    'Wi-Fi',
    'WiFi',
    'CCTV',
    'LED',
    'USB',
    'GPS',
    'QR',
    'iPhone',
  };

  for (final token in tokens) {
    if (allowed.contains(token)) {
      continue;
    }

    if (token.length <= 5 && token == token.toUpperCase()) {
      continue;
    }

    return false;
  }

  return true;
}
