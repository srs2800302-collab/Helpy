import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../utils/translation_display.dart';

class JobReviewSummary extends StatelessWidget {
  final int? rating;
  final String? comment;
  final String? commentTranslationsJson;
  final bool submitted;

  const JobReviewSummary({
    super.key,
    required this.rating,
    required this.comment,
    this.commentTranslationsJson,
    this.submitted = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final safeRating = (rating ?? 0).clamp(0, 5);
    final text = translatedOrOriginal(
      original: comment,
      translationsJson: commentTranslationsJson,
      locale: l10n.locale.languageCode,
    ).trim();

    if (safeRating <= 0 && text.isEmpty && !submitted) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  submitted ? l10n.t('review_submitted') : l10n.t('review'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (safeRating > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < safeRating ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.amber.shade700,
                ),
              ),
            ),
          ],
          if (text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

class LeaveReviewButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const LeaveReviewButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.star_rate_rounded),
          label: Text(l10n.t('submit_review')),
        ),
      ),
    );
  }
}
