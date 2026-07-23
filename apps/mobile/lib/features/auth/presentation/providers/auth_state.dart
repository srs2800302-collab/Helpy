import '../../domain/auth_session.dart';

class AuthState {
  final bool isLoading;
  final bool initialized;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.initialized = false,
    this.session,
    this.errorMessage,
  });

  bool get isAuthenticated => session != null;

  AuthState copyWith({
    bool? isLoading,
    bool? initialized,
    AuthSession? session,
    String? errorMessage,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
