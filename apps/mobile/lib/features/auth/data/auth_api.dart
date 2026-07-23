import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

const _roleSwitcherEmails = <String>{
  'tester@fixi.dev',
};

bool canSwitchRoleForEmail(String email) {
  final normalized = email.trim().toLowerCase();
  return _roleSwitcherEmails.contains(normalized);
}

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<AuthSession> signInWithGoogle(String idToken) async {
    final response = await apiClient.post(
      '/auth/google',
      data: {
        'id_token': idToken,
      },
    );

    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSession> selectRole(UserRole role) async {
    final response = await apiClient.post(
      '/auth/select-my-role',
      data: {
        'role': _roleToApiValue(role),
      },
    );

    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSession> getCurrentUser() async {
    final response = await apiClient.get('/auth/me');
    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  Future<RefreshTokensResult?> refreshAccessToken(String refreshToken) async {
    final response = await apiClient.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>?;

    final accessToken = tokens?['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    return RefreshTokensResult(
      accessToken: accessToken,
      refreshToken: tokens?['refreshToken']?.toString(),
    );
  }

  AuthSession _mapSession(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tokens = json['tokens'] as Map<String, dynamic>;

    final role = _mapRole(user['role']?.toString());
    final email = user['email'].toString();
    final canSwitchRole = canSwitchRoleForEmail(email);
    final isNewUser = role == null;

    return AuthSession(
      userId: user['id'].toString(),
      email: email,
      role: role,
      isNewUser: isNewUser,
      needsRoleSelection: canSwitchRole || isNewUser,
      accessToken: tokens['accessToken'].toString(),
      refreshToken: tokens['refreshToken']?.toString() ?? '',
    );
  }

  UserRole? _mapRole(String? value) {
    switch (value) {
      case 'client':
        return UserRole.client;
      case 'master':
        return UserRole.master;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }

  String _roleToApiValue(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'client';
      case UserRole.master:
        return 'master';
      case UserRole.admin:
        return 'admin';
    }
  }
}
