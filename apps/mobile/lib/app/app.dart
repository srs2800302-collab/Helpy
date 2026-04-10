import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/localization/app_localizations.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FixiApp extends ConsumerStatefulWidget {
  const FixiApp({super.key});

  @override
  ConsumerState<FixiApp> createState() => _FixiAppState();
}

class _FixiAppState extends ConsumerState<FixiApp> {
  late final AuthRouterNotifier _routerNotifier;

  @override
  void initState() {
    super.initState();
    _routerNotifier = AuthRouterNotifier(const AuthState());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      _routerNotifier.update(next);
    });

    final router = createRouter(_routerNotifier);

    return MaterialApp.router(
      title: 'Fixi',
      theme: buildAppTheme(),
      routerConfig: router,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('th'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  @override
  void dispose() {
    _routerNotifier.dispose();
    super.dispose();
  }
}
