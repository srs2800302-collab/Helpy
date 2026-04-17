import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HelpySplashScreen extends StatefulWidget {
  final Widget child;

  const HelpySplashScreen({
    super.key,
    required this.child,
  });

  @override
  State<HelpySplashScreen> createState() => _HelpySplashScreenState();
}

class _HelpySplashScreenState extends State<HelpySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _showSplash
              ? ColoredBox(
                  key: const ValueKey('helpy_splash'),
                  color: const Color(0xFFFFFFFF),
                  child: SafeArea(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: curve,
                        builder: (context, child) {
                          final wave = math.sin(curve.value * math.pi * 2);
                          final floatY = wave * 10;
                          final tilt = wave * 0.03;
                          final scale = 1.0 + ((wave + 1) / 2) * 0.05;

                          return Transform.translate(
                            offset: Offset(0, floatY),
                            child: Transform.rotate(
                              angle: tilt,
                              child: Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Helpy',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/icon.png',
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 28),
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('helpy_app')),
        ),
      ],
    );
  }
}
