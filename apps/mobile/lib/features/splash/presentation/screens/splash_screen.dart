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
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    Future.microtask(() async {
      if (_initialized) return;
      _initialized = true;

      await Future.delayed(const Duration(milliseconds: 3200));
      if (!mounted) return;

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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final moveX = (t - 0.5) * screen.width * 0.42;
          final bounce = math.sin(t * math.pi * 10) * 18;
          final tilt = math.sin(t * math.pi * 4) * 0.08;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/beach.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: screen.width * 0.5 - (screen.width * 0.32) + moveX,
                bottom: screen.height * 0.08 + bounce,
                child: Transform.rotate(
                  angle: tilt,
                  child: Image.asset(
                    'assets/crab.png',
                    width: screen.width * 0.64,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Positioned(
                top: 42,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
