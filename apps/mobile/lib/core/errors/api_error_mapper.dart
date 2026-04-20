import 'package:dio/dio.dart';

import 'app_exception.dart';

class ApiErrorMapper {
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

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppException(
            message: 'Request timeout. Please try again.',
            code: 'timeout',
          );

        case DioExceptionType.connectionError:
          return const AppException(
            message: 'No internet connection.',
            code: 'connection_error',
          );

        case DioExceptionType.badResponse:
          if (statusCode == 401) {
            return AppException(
              message: backendMessage ?? 'Session expired. Please sign in again.',
              code: 'unauthorized',
              statusCode: statusCode,
            );
          }

          if (statusCode == 403) {
            return AppException(
              message: backendMessage ?? 'You do not have access to this action.',
              code: 'forbidden',
              statusCode: statusCode,
            );
          }

          if (statusCode == 404) {
            return AppException(
              message: backendMessage ?? 'Requested resource was not found.',
              code: 'not_found',
              statusCode: statusCode,
            );
          }

          if (statusCode == 409) {
            return AppException(
              message: backendMessage ?? 'This action has already been performed.',
              code: 'conflict',
              statusCode: statusCode,
            );
          }

          if (statusCode == 422 || statusCode == 400) {
            return AppException(
              message: backendMessage ?? 'Invalid request data.',
              code: 'bad_request',
              statusCode: statusCode,
            );
          }

          return AppException(
            message: backendMessage ?? 'Server error. Please try again later.',
            code: 'server_error',
            statusCode: statusCode,
          );

        case DioExceptionType.cancel:
          return const AppException(
            message: 'Request was cancelled.',
            code: 'cancelled',
          );

        case DioExceptionType.unknown:
          return AppException(
            message: backendMessage ?? 'Unexpected error occurred.',
            code: 'unknown',
            statusCode: statusCode,
          );

        case DioExceptionType.badCertificate:
          return const AppException(
            message: 'Secure connection failed.',
            code: 'bad_certificate',
          );
      }
    }

    return AppException(
      message: error.toString(),
      code: 'unknown',
    );
  }
}
