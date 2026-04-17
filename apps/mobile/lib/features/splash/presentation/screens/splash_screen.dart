import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    Future.microtask(() async {
      if (_initialized) return;
      _initialized = true;
      await ref.read(authControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final wave = math.sin(_controller.value * math.pi * 2);
          final scale = 1.0 + ((wave + 1) / 2) * 0.04;
          final offsetY = wave * 8;

          return Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Image.asset(
                'assets/icon.png',
                width: screen.width * 0.92,
                height: screen.height * 0.75,
                fit: BoxFit.contain,
              ),
            ),
            const Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
