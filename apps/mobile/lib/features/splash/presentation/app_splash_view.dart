import 'package:flutter/material.dart';

class AppSplashView extends StatelessWidget {
  const AppSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/crab.gif'),
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
