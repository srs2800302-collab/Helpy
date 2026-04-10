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
  late final Object _authListener;
  late final router;

  @override
  void initState() {
    super.initState();
    _routerNotifier = AuthRouterNotifier(const AuthState());
    router = createRouter(_routerNotifier);

    _authListener = ref.listenManual<AuthState>(
      authControllerProvider,
      (_, next) {
        _routerNotifier.update(next);
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
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
    (_authListener as ProviderSubscription<AuthState>).close();
    _routerNotifier.dispose();
    super.dispose();
  }
}
