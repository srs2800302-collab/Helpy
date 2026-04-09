import 'package:flutter/material.dart';
import 'features/auth/screens/login_phone_screen.dart';

void main() {
  runApp(const FixiApp());
}

class FixiApp extends StatelessWidget {
  const FixiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPhoneScreen(),
    );
  }
}
