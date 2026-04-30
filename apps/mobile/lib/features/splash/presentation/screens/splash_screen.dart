import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../app_splash_view.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized || !mounted) return;
      _initialized = true;
      await ref.read(authControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppSplashView(),
    );
  }
}
