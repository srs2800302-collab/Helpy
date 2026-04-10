enum UserRole {
  client,
  master,
  admin,
}

class AuthSession {
  final String userId;
  final String phone;
  final UserRole? role;
  final bool isNewUser;
  final bool needsRoleSelection;
  final String accessToken;
  final String refreshToken;

  const AuthSession({
    required this.userId,
    required this.phone,
    required this.role,
    required this.isNewUser,
    required this.needsRoleSelection,
    required this.accessToken,
    required this.refreshToken,
  });
}
