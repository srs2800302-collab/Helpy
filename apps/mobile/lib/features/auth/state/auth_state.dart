import '../models/auth_session.dart';

class AuthState {
  final bool isLoading;
  final String phone;
  final String otpCode;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.phone = '',
    this.otpCode = '',
    this.session,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? phone,
    String? otpCode,
    AuthSession? session,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      otpCode: otpCode ?? this.otpCode,
      session: session ?? this.session,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
