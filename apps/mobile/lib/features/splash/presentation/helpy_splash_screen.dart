import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HelpySplashScreen extends StatefulWidget {
  final Widget next;

  const HelpySplashScreen({
    super.key,
    required this.next,
  });

  @override
  State<HelpySplashScreen> createState() => _HelpySplashScreenState();
}

class _HelpySplashScreenState extends State<HelpySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => widget.next,
        ),
      );
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: curve,
            builder: (context, child) {
              final dx = math.sin(curve.value * math.pi * 2) * 10;
              final dy = math.cos(curve.value * math.pi * 2) * 6;
              final scale = 1 + (curve.value * 0.04);

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.scale(
                  scale: scale,
                  child: child,
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
                const SizedBox(height: 24),
                Image.asset(
                  'assets/icon.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
