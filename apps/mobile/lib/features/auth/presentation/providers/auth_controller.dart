import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../domain/auth_session.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final storage = ref.read(tokenStorageProvider);
      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();

      if (accessToken == null || accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          initialized: true,
          clearSession: true,
        );
        return;
      }

      final api = ref.read(authApiProvider);
      final current = await api.getCurrentUser(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        session: current,
      );
    } catch (e) {
      await ref.read(tokenStorageProvider).clearAll();
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        clearSession: true,
        errorMessage: e.toString(),
      );
    }
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value, clearError: true);
  }

  void setOtpCode(String value) {
    state = state.copyWith(otpCode: value, clearError: true);
  }

  Future<bool> requestOtp() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authApiProvider).requestOtp(state.phone.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await ref.read(authApiProvider).verifyOtp(
            state.phone.trim(),
            state.otpCode.trim(),
          );

      final storage = ref.read(tokenStorageProvider);
      await storage.saveAccessToken(session.accessToken);
      await storage.saveRefreshToken(session.refreshToken);

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> selectRole(UserRole role) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final current = state.session;
      if (current == null) {
        throw Exception('No active session');
      }

      final updated = await ref.read(authApiProvider).selectRole(
            role: role == UserRole.client ? 'client' : 'master',
            accessToken: current.accessToken,
            refreshToken: current.refreshToken,
          );

      state = state.copyWith(
        isLoading: false,
        session: updated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearAll();
    state = const AuthState(initialized: true);
  }
}
