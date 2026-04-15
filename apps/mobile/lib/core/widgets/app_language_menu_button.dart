import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../localization/app_localizations.dart';

class AppLanguageMenuButton extends ConsumerWidget {
  const AppLanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);

    return PopupMenuButton<String>(
      tooltip: l10n.t('language'),
      initialValue: currentLocale.languageCode,
      onSelected: (value) {
        final locale = switch (value) {
          'ru' => const Locale('ru'),
          'en' => const Locale('en'),
          'th' => const Locale('th'),
          _ => const Locale('ru'),
        };
        ref.read(currentLocaleProvider.notifier).state = locale;
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'ru', child: Text(l10n.t('russian'))),
        PopupMenuItem(value: 'en', child: Text(l10n.t('english'))),
        PopupMenuItem(value: 'th', child: Text(l10n.t('thai'))),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          Icons.language,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}
