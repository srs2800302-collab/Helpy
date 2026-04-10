import 'package:flutter/material.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../client_home/presentation/screens/client_home_screen.dart';
import '../../../master_home/presentation/screens/master_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserRole? role;

  const HomeScreen({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.client:
        return const ClientHomeScreen();
      case UserRole.master:
        return const MasterHomeScreen();
      case UserRole.admin:
        return const ClientHomeScreen();
      case null:
        return const Scaffold(
          body: Center(
            child: Text('Role is not selected'),
          ),
        );
    }
  }
}
