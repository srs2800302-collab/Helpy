import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(jobTitle),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: controller.setMessage,
              enabled: !isBusy,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_message'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: controller.setPrice,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '${l10n.t('price_label')} (THB)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: controller.setPriceComment,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('offer_price_comment'),
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isBusy || state.price.trim().isEmpty)
                    ? null
                    : () async {
                        final ok = await controller.createOffer(jobId: jobId);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop(true);
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
