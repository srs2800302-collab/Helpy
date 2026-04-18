import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';

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

    Future.microtask(() async {
      if (_initialized) return;
      _initialized = true;

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      await ref.read(authControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/beach.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              'assets/crab.gif',
              width: 220,
            ),
          ),
        ],
      ),
    );
  }
}
