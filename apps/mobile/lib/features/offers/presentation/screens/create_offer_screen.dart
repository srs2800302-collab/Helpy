import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';

class CreateOfferScreen extends ConsumerWidget {
  final String jobId;
  final String jobTitle;
  final String? jobTitleTranslationsJson;

  const CreateOfferScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.jobTitleTranslationsJson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final isBusy = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('send_offer')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (value) {
              controller.setMessage(value);
              controller.previewMessageTranslations(value);
            },
            enabled: !isBusy,
            maxLines: 2,
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
            onChanged: (value) {
              controller.setPriceComment(value);
              controller.previewPriceCommentTranslations(value);
            },
            enabled: !isBusy,
            minLines: 6,
            maxLines: 10,
            inputFormatters: [
              LengthLimitingTextInputFormatter(700),
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              labelText: l10n.t('offer_price_comment'),
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.t(state.errorMessage!),
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 8),
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
    );
  }

}
