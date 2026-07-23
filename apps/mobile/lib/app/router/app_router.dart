import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/google_sign_in_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

GoRouter createRouter(ValueNotifier<AuthState> authNotifier) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = authNotifier.value;
      final location = state.matchedLocation;

      if (!auth.initialized) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthenticated = auth.session != null;
      final isAuthRoute = location == '/login' || location == '/splash';
      final isRoleRoute = location == '/select-role';
      final needsRoleSelection = auth.session?.needsRoleSelection == true;

      if (!isAuthenticated) {
        return location == '/login' ? null : '/login';
      }

      if (isRoleRoute) {
        return needsRoleSelection ? null : '/home';
      }

      if (isAuthRoute) {
        return needsRoleSelection ? '/select-role' : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const GoogleSignInScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}

class AuthRouterNotifier extends ValueNotifier<AuthState> {
  AuthRouterNotifier(super.value);

  void update(AuthState state) {
    value = state;
  }
}
