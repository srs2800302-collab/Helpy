import 'package:flutter/material.dart';

void main() {
  runApp(const FixiApp());
}

class FixiApp extends StatelessWidget {
  const FixiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixi',
      home: Scaffold(
        body: Center(
          child: Text('Fixi foundation ready'),
        ),
      ),
    );
  }
}
