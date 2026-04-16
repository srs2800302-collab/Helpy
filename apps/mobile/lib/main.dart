import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'features/splash/presentation/helpy_splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HelpySplashScreen(
        next: FixiApp(),
      ),
    ),
  );
}
