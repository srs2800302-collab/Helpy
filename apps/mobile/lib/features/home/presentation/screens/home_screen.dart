import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../client_home/presentation/screens/client_home_screen.dart';
import '../../../master_home/presentation/screens/master_home_screen.dart';
import '../../../auth/domain/auth_session.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    switch (authState.session?.role) {
      case UserRole.client:
        return const ClientHomeScreen();
      case UserRole.master:
        return const MasterHomeScreen();
      case UserRole.admin:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('home_title'))),
          body: Center(
            child: Text(l10n.t('not_implemented')),
          ),
        );
      case null:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.t('home_title'))),
          body: Center(
            child: Text(l10n.t('choose_role')),
          ),
        );
    }
  }
}
