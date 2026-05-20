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

  void setPhone(String value) {
    state = state.copyWith(
      phone: value,
      clearError: true,
    );
  }

  void setOtpCode(String value) {
    state = state.copyWith(
      otpCode: value,
      clearError: true,
    );
  }

  Future<bool> requestOtp() async {
    final normalizedPhone = _normalizePhone(state.phone);

    if (!_isPhoneValid(normalizedPhone)) {
      state = state.copyWith(
        errorMessage: _t('validation_phone_invalid'),
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      phone: normalizedPhone,
    );

    try {

      await ref.read(authApiProvider).requestOtp(normalizedPhone);
      state = state.copyWith(isLoading: false);
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

  Future<bool> verifyOtp() async {
    final normalizedPhone = _normalizePhone(state.phone);
    final normalizedOtp = _normalizeOtp(state.otpCode);

    if (!_isPhoneValid(normalizedPhone)) {
      state = state.copyWith(
        errorMessage: _t('validation_phone_invalid'),
      );
      return false;
    }

    if (!_isOtpValid(normalizedOtp)) {
      state = state.copyWith(
        errorMessage: _t('validation_otp_invalid'),
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      phone: normalizedPhone,
      otpCode: normalizedOtp,
    );

    try {
      final session = await ref.read(authApiProvider).verifyOtp(
            normalizedPhone,
            normalizedOtp,
          );

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
      phone: '',
      otpCode: '',
      clearSession: true,
      clearError: true,
    );
  }

  String _normalizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('+')) {
      final digits = trimmed.substring(1).replaceAll(RegExp(r'\D'), '');
      return '+$digits';
    }
    return trimmed.replaceAll(RegExp(r'\D'), '');
  }

  String _normalizeOtp(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool _isPhoneValid(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  bool _isOtpValid(String value) {
    return value.length == 6;
  }

  String _t(String key) {
    switch (key) {
      case 'validation_phone_invalid':
        return 'validation_phone_invalid';
      case 'validation_otp_invalid':
        return 'validation_otp_invalid';
      default:
        return key;
    }
  }
}
