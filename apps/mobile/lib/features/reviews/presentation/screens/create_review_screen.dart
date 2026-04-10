// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class CreateReviewScreen extends ConsumerWidget {
  final String jobId;

  const CreateReviewScreen({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsControllerProvider);
    final controller = ref.read(reviewsControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final isBusy = state.isSubmitting;
    final trimmedComment = state.comment.trim();
    final isCommentValid = trimmedComment.length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('review')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: state.rating,
              items: const [1, 2, 3, 4, 5]
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    ),
                  )
                  .toList(),
              onChanged: isBusy
                  ? null
                  : (value) {
                      if (value != null) controller.setRating(value);
                    },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('rating'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: controller.setComment,
              enabled: !isBusy,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('comment'),
                helperText: trimmedComment.isEmpty || isCommentValid
                    ? null
                    : 'Minimum 3 characters',
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (state.successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBusy || !isCommentValid
                    ? null
                    : () async {
                        final ok = await controller.createReview(jobId: jobId);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('submit_review')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
