import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/auth_session.dart';
import 'auth_state.dart';


class AuthController extends StateNotifier<AuthState> {
  static const _sessionTimeout = Duration(minutes: 5);

  final Ref ref;

  AuthController(this.ref) : super(const AuthState());

  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final backgroundedAtRaw = await _storage.getBackgroundedAt();

      if (backgroundedAtRaw != null) {
        final backgroundedAt = DateTime.tryParse(backgroundedAtRaw);
        if (backgroundedAt != null &&
            DateTime.now().difference(backgroundedAt) >= _sessionTimeout) {
          await _clearSessionState();
          return;
        }

        await _storage.clearBackgroundedAt();
      }

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          initialized: true,
          clearSession: true,
        );
        return;
      }

      final current = await ref.read(authApiProvider).getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        session: current,
      );
    } catch (e) {
      await _storage.clearAll();
      final appError = ApiErrorMapper.map(e);

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        clearSession: true,
        errorMessage: appError.message,
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final account = await googleSignIn.signIn();

      if (account == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'google_sign_in_failed',
        );
        return false;
      }

      final session = await ref.read(authApiProvider).signInWithGoogle(idToken);
      await _activateSession(session);
      return true;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
      return false;
    }
  }

  Future<void> selectRole(UserRole role) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updated = await ref.read(authApiProvider).selectRole(role);
      await _activateSession(updated);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
    }
  }

  Future<void> handleSessionExpired() async {
    await _clearSessionState();
  }

  Future<void> logout() async {
    await ref.read(googleSignInProvider).signOut();
    await _storage.clearAll();
    state = const AuthState(initialized: true);
  }

  Future<void> _activateSession(
    AuthSession session, {
    bool persistTokens = true,
  }) async {
    if (persistTokens) {
      await _storage.saveAccessToken(session.accessToken);
      await _storage.saveRefreshToken(session.refreshToken);
    }
    await _storage.clearBackgroundedAt();

    state = state.copyWith(
      isLoading: false,
      initialized: true,
      session: session,
    );
  }

  Future<void> _clearSessionState() async {
    await _storage.clearAll();
    state = state.copyWith(
      isLoading: false,
      initialized: true,
      clearSession: true,
      clearError: true,
    );
  }
}
