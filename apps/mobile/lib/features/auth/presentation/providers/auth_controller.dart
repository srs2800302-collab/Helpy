import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/auth_session.dart';
import 'auth_state.dart';

const _debugClientUserId = '6570ea80-6707-4c0d-87e8-6b5de0bac878';
const _debugMasterUserId = '2cb75bef-d020-4b33-ad76-8573346f6f82';
const _debugOtpCode = '123456';
const _debugPhoneFallback = '+70000000000';

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
      final refreshToken = await _storage.getRefreshToken();

      if (accessToken == null || accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          initialized: true,
          clearSession: true,
        );
        return;
      }

      if (kDebugMode && accessToken.startsWith('debug_')) {
        await _activateSession(
          AuthSession(
            userId: _debugClientUserId,
            phone: state.phone.isNotEmpty ? state.phone : _debugPhoneFallback,
            role: null,
            isNewUser: false,
            needsRoleSelection: true,
            accessToken: accessToken,
            refreshToken: refreshToken ?? 'debug_refresh_token',
          ),
          persistTokens: false,
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
      if (kDebugMode) {
        state = state.copyWith(isLoading: false);
        return true;
      }

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
      if (kDebugMode) {
        if (normalizedOtp != _debugOtpCode) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Debug OTP: $_debugOtpCode',
          );
          return false;
        }

        await _activateSession(
          AuthSession(
            userId: _debugClientUserId,
            phone: normalizedPhone,
            role: null,
            isNewUser: false,
            needsRoleSelection: true,
            accessToken: 'debug_access_token',
            refreshToken: 'debug_refresh_token',
          ),
        );
        return true;
      }

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
      final currentSession = state.session;
      final isDebugSession = kDebugMode &&
          currentSession != null &&
          currentSession.accessToken.startsWith('debug_');

      if (isDebugSession) {
        final userId =
            role == UserRole.master ? _debugMasterUserId : _debugClientUserId;

        await _activateSession(
          AuthSession(
            userId: userId,
            phone: currentSession.phone,
            role: role,
            isNewUser: false,
            needsRoleSelection: false,
            accessToken: currentSession.accessToken,
            refreshToken: currentSession.refreshToken,
          ),
          persistTokens: false,
        );
        return;
      }

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
