import '../../auth/domain/auth_session.dart';
import '../../../core/network/api_client.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<void> requestOtp(String phone) async {
    await apiClient.dio.post(
      '/auth/request-otp',
      data: {
        'phone': phone,
      },
    );
  }

  Future<AuthSession> verifyOtp(String phone, String code) async {
    final response = await apiClient.dio.post(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'code': code,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;

    return AuthSession(
      userId: user['id'] as String,
      phone: user['phone'] as String,
      role: _parseRole(user['role'] as String?),
      isNewUser: data['isNewUser'] as bool? ?? false,
      needsRoleSelection: data['needsRoleSelection'] as bool? ?? false,
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
  }

  Future<AuthSession> getCurrentUser({
    required String accessToken,
    required String refreshToken,
  }) async {
    final response = await apiClient.dio.get('/auth/me');
    final data = response.data['data'] as Map<String, dynamic>;

    return AuthSession(
      userId: data['id'] as String,
      phone: data['phone'] as String,
      role: _parseRole(data['role'] as String?),
      isNewUser: false,
      needsRoleSelection: (data['role'] == null),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<AuthSession> selectRole({
    required String role,
    required String accessToken,
    required String refreshToken,
  }) async {
    final response = await apiClient.dio.post(
      '/auth/select-role',
      data: {'role': role},
    );
    final data = response.data['data'] as Map<String, dynamic>;

    return AuthSession(
      userId: data['id'] as String,
      phone: data['phone'] as String,
      role: _parseRole(data['role'] as String?),
      isNewUser: false,
      needsRoleSelection: (data['role'] == null),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  UserRole? _parseRole(String? value) {
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
}
