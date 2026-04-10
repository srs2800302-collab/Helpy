import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class CreateOfferScreen extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const CreateOfferScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final isBusy = state.isSubmitting;
    final trimmedMessage = state.message.trim();
    final trimmedPriceComment = state.priceComment.trim();
    final hasAnyContent = trimmedMessage.isNotEmpty || trimmedPriceComment.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(jobTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: controller.setMessage,
              enabled: !isBusy,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_message'),
                helperText: hasAnyContent ? null : 'Enter a message or price comment',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: controller.setPriceComment,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_price_comment'),
                helperText: hasAnyContent ? null : 'Enter a message or price comment',
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
                onPressed: isBusy || !hasAnyContent
                    ? null
                    : () async {
                        final ok = await controller.createOffer(jobId: jobId);
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
                    : Text(l10n.t('send_offer')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
