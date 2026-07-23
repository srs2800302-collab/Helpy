import 'package:flutter/material.dart';

/// A simple reusable button widget used on the Dashboard screen.
/// Currently it shows a placeholder dialog when pressed.
class DashboardActionButton extends StatelessWidget {
  const DashboardActionButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Новая кнопка'),
    );
  }
}
