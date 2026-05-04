import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../client_home/presentation/screens/client_home_screen.dart';
import '../../../master_home/presentation/screens/master_home_screen.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../../splash/presentation/app_splash_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  static const _sessionTimeout = Duration(minutes: 5);

  DateTime? _pausedAt;
  bool _isHandlingTimeout = false;
  bool _showResumeSplash = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        final now = DateTime.now();
        _pausedAt = now;
        ref.read(tokenStorageProvider).saveBackgroundedAt(now.toIso8601String());
        break;
      case AppLifecycleState.resumed:
        setState(() {
          _showResumeSplash = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _showResumeSplash = false;
          });
        });
        _handleResumeTimeout();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _handleResumeTimeout() async {
    if (_isHandlingTimeout || !mounted) return;

    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) return;

    final elapsed = DateTime.now().difference(pausedAt);
    final authState = ref.read(authControllerProvider);
    final storage = ref.read(tokenStorageProvider);

    if (authState.session == null) {
      await storage.clearBackgroundedAt();
      return;
    }

    if (elapsed < _sessionTimeout) {
      await storage.clearBackgroundedAt();
      return;
    }

    _isHandlingTimeout = true;
    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    } finally {
      _isHandlingTimeout = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    final Widget child = switch (authState.session?.role) {
      UserRole.client => const ClientHomeScreen(),
      UserRole.master => const MasterHomeScreen(),
      UserRole.admin => Scaffold(
          appBar: AppBar(title: Text(l10n.t('home_title'))),
          body: Center(
            child: Text(l10n.t('not_implemented')),
          ),
        ),
      null => const RoleSelectionScreen(),
    };

    return Stack(
      children: [
        child,
        if (_showResumeSplash) const Positioned.fill(child: AppSplashView()),
      ],
    );
  }
}
