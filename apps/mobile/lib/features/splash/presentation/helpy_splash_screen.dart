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
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _timer = Timer(const Duration(milliseconds: 4000), () {
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
    final wave = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    final screen = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _showSplash
              ? ColoredBox(
                  key: const ValueKey('helpy_splash'),
                  color: const Color(0xFFFFFFFF),
                  child: AnimatedBuilder(
                    animation: wave,
                    builder: (context, child) {
                      final v = math.sin(wave.value * math.pi * 2);
                      final scale = 1.0 + ((v + 1) / 2) * 0.05;

                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.contain,
                              width: screen.width * 0.92,
                              height: screen.height * 0.75,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
