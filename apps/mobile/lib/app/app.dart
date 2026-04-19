import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class _FixiAppState extends ConsumerState<FixiApp> with WidgetsBindingObserver {
  static const _sessionTimeout = Duration(minutes: 5);

  late final AuthRouterNotifier _routerNotifier;
  late final Object _authListener;
  late final Object _sessionExpiredListener;
  late final GoRouter router;

  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _routerNotifier = AuthRouterNotifier(const AuthState());
    router = createRouter(_routerNotifier);

    _authListener = ref.listenManual<AuthState>(
      authControllerProvider,
      (_, next) {
        _routerNotifier.update(next);
      },
      fireImmediately: true,
    );

    _sessionExpiredListener = ref.listenManual<int>(
      sessionExpiredTickProvider,
      (previous, next) async {
        if (previous == next) return;
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _pausedAt = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        final pausedAt = _pausedAt;
        _pausedAt = null;

        if (pausedAt == null) return;

        final elapsed = DateTime.now().difference(pausedAt);
        final authState = ref.read(authControllerProvider);

        if (authState.session != null && elapsed >= _sessionTimeout) {
          ref.read(sessionExpiredTickProvider.notifier).state++;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Helpy',
      theme: buildAppTheme(),
      locale: currentLocale,
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
    WidgetsBinding.instance.removeObserver(this);
    (_authListener as ProviderSubscription<AuthState>).close();
    (_sessionExpiredListener as ProviderSubscription<int>).close();
    _routerNotifier.dispose();
    super.dispose();
  }
}
