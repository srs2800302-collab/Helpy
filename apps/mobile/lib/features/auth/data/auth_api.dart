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

    return AuthSession(
      userId: user['id'].toString(),
      phone: user['phone'].toString(),
      role: user['role']?.toString(),
      accessToken: tokens['accessToken'].toString(),
      refreshToken: tokens['refreshToken']?.toString() ?? '',
      isNewUser: user['role'] == null,
    );
  }
}
