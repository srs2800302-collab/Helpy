import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class LoginPhoneScreen extends ConsumerWidget {
  const LoginPhoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('login_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.t('enter_phone'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: controller.setPhone,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.t('phone_hint'),
                labelText: 'Phone',
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final ok = await controller.requestOtp();
                        if (ok && context.mounted) {
                          context.go('/verify-otp');
                        }
                      },
                child: Text(l10n.t('request_otp')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
