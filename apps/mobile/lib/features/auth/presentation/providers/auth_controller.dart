import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/auth_session.dart';
import 'auth_state.dart';

const _debugClientUserId = '6570ea80-6707-4c0d-87e8-6b5de0bac878';
const _debugOtpCode = '123456';
const _debugPhoneFallback = '+70000000000';

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

      if (kDebugMode && accessToken.startsWith('debug_')) {
        state = state.copyWith(
          isLoading: false,
          initialized: true,
          session: AuthSession(
            userId: _debugClientUserId,
            phone: state.phone.isNotEmpty ? state.phone : _debugPhoneFallback,
            role: UserRole.client,
            isNewUser: false,
            needsRoleSelection: false,
            accessToken: accessToken,
            refreshToken: refreshToken ?? 'debug_refresh_token',
          ),
        );
        return;
      }

      final api = ref.read(authApiProvider);
      final current = await api.getCurrentUser();

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        session: current,
      );
    } catch (e) {
      await ref.read(tokenStorageProvider).clearAll();
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

        final session = AuthSession(
          userId: _debugClientUserId,
          phone: normalizedPhone,
          role: UserRole.client,
          isNewUser: false,
          needsRoleSelection: false,
          accessToken: 'debug_access_token',
          refreshToken: 'debug_refresh_token',
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
      }

      final session = await ref.read(authApiProvider).verifyOtp(
            normalizedPhone,
            normalizedOtp,
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

      final storage = ref.read(tokenStorageProvider);
      await storage.saveAccessToken(updated.accessToken);
      await storage.saveRefreshToken(updated.refreshToken);

      state = state.copyWith(
        isLoading: false,
        session: updated,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
    }
  }

  Future<void> handleSessionExpired() async {
    await ref.read(tokenStorageProvider).clearAll();
    state = state.copyWith(
      isLoading: false,
      initialized: true,
      phone: '',
      otpCode: '',
      clearSession: true,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearAll();
    state = const AuthState(initialized: true);
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
