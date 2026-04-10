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
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_message'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: controller.setPriceComment,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_price_comment'),
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            if (state.successMessage != null) ...[
              Text(
                state.successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final ok = await controller.createOffer(jobId: jobId);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(l10n.t('send_offer')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
