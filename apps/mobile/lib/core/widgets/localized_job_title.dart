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
    final primary =
        displayTitle.trim().isNotEmpty ? displayTitle.trim() : originalTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: primaryStyle,
        ),
        if (hasRealTranslation(
          original: originalTitle,
          translated: displayTitle,
        )) ...[
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
