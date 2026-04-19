import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class VerifyOtpScreen extends ConsumerWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final isBusy = state.isLoading;

    Future<void> submit() async {
      await controller.verifyOtp();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('verify_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.t('enter_otp'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: controller.setOtpCode,
              onSubmitted: (_) {
                if (!isBusy) {
                  submit();
                }
              },
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.t('otp_hint'),
                labelText: l10n.t('enter_otp'),
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
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBusy ? null : submit,
                child: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('verify')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
