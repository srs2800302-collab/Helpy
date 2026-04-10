import '../../domain/auth_session.dart';

class AuthState {
  final bool isLoading;
  final bool initialized;
  final String phone;
  final String otpCode;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.initialized = false,
    this.phone = '',
    this.otpCode = '',
    this.session,
    this.errorMessage,
  });

  bool get isAuthenticated => session != null;

  bool get isPhoneValid {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  bool get isOtpValid {
    final digits = otpCode.replaceAll(RegExp(r'\D'), '');
    return digits.length == 6;
  }

  AuthState copyWith({
    bool? isLoading,
    bool? initialized,
    String? phone,
    String? otpCode,
    AuthSession? session,
    String? errorMessage,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      phone: phone ?? this.phone,
      otpCode: otpCode ?? this.otpCode,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
