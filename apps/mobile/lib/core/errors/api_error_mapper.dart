import 'package:dio/dio.dart';

import 'app_exception.dart';

class ApiErrorMapper {
  static String? _backendMessageKey(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final isKey = RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(raw);
    return isKey ? raw : null;
  }

  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String? backendMessage;
      if (data is Map) {
        final errorNode = data['error'];
        if (errorNode is String && errorNode.trim().isNotEmpty) {
          backendMessage = errorNode.trim();
        } else if (errorNode is Map && errorNode['message'] != null) {
          backendMessage = errorNode['message'].toString();
        }
      }

      final backendKey = _backendMessageKey(backendMessage);

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppException(
            message: 'error_timeout',
            code: 'timeout',
          );

        case DioExceptionType.connectionError:
          return const AppException(
            message: 'error_connection',
            code: 'connection_error',
          );

        case DioExceptionType.badResponse:
          if (statusCode == 401) {
            return AppException(
              message: backendKey ?? 'error_unauthorized',
              code: 'unauthorized',
              statusCode: statusCode,
            );
          }

          if (statusCode == 403) {
            return AppException(
              message: backendKey ?? 'error_forbidden',
              code: 'forbidden',
              statusCode: statusCode,
            );
          }

          if (statusCode == 404) {
            return AppException(
              message: backendKey ?? 'error_not_found',
              code: 'not_found',
              statusCode: statusCode,
            );
          }

          if (statusCode == 409) {
            return AppException(
              message: backendKey ?? 'error_conflict',
              code: 'conflict',
              statusCode: statusCode,
            );
          }

          if (statusCode == 422 || statusCode == 400) {
            return AppException(
              message: backendKey ?? 'error_bad_request',
              code: 'bad_request',
              statusCode: statusCode,
            );
          }

          return AppException(
            message: backendKey ?? 'server_error',
            code: 'server_error',
            statusCode: statusCode,
          );

        case DioExceptionType.cancel:
          return const AppException(
            message: 'error_cancelled',
            code: 'cancelled',
          );

        case DioExceptionType.unknown:
          return AppException(
            message: backendKey ?? 'error_unknown',
            code: 'unknown',
            statusCode: statusCode,
          );

        case DioExceptionType.badCertificate:
          return const AppException(
            message: 'error_bad_certificate',
            code: 'bad_certificate',
          );
      }
    }

    return const AppException(
      message: 'error_unknown',
      code: 'unknown',
    );
  }
}
