import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<void> requestOtp(String phone) async {
    await apiClient.post(
      '/auth/request-otp',
      data: {
        'phone': phone,
      },
    );
  }

  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await apiClient.post(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'code': code,
      },
    );

    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSession> selectMyRole({
    required String role,
  }) async {
    final response = await apiClient.post(
      '/auth/select-my-role',
      data: {
        'role': role,
      },
    );

    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSession> refreshAccessToken(String refreshToken) async {
    final response = await apiClient.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    return _mapSession(response.data['data'] as Map<String, dynamic>);
  }

  AuthSession _mapSession(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['user']['id'] as String,
      phone: json['user']['phone'] as String,
      role: _mapRole(json['user']['role'] as String?),
      accessToken: json['tokens']['accessToken'] as String,
      refreshToken: json['tokens']['refreshToken'] as String?,
      needsRoleSelection: (json['user']['role'] as String?) == null,
    );
  }

  AuthRole? _mapRole(String? value) {
    switch (value) {
      case 'client':
        return AuthRole.client;
      case 'master':
        return AuthRole.master;
      case 'admin':
        return AuthRole.admin;
      default:
        return null;
    }
  }
}
