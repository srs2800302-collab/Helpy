import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

typedef RefreshTokensFn = Future<RefreshTokensResult?> Function(String refreshToken);

class RefreshTokensResult {
  final String accessToken;
  final String? refreshToken;

  const RefreshTokensResult({
    required this.accessToken,
    required this.refreshToken,
  });
}


class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RefreshTokensFn? _refreshTokensFn;
  void Function()? _unauthorizedHandler;
  bool _isRefreshing = false;
  Future<RefreshTokensResult?>? _refreshFuture;

  ApiClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
  })  : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ),
        _tokenStorage = tokenStorage {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          final isDebugToken =
              kDebugMode && (token?.startsWith('debug_') ?? false);

          if (isDebugToken) {
            options.headers.remove('Authorization');
            final debugUserId = token!.replaceFirst('debug_', '');
                options.headers['x-user-id'] = debugUserId;
          } else if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;

          if (data is Map && data['success'] == false) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                message: data['error']?.toString() ?? 'Unknown error',
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          handler.next(response);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;
          final alreadyRetried = requestOptions.extra['retried'] == true;
          final isRefreshCall = requestOptions.path.contains('/auth/refresh');
          final currentToken = await _tokenStorage.getAccessToken();
          final isDebugToken =
              kDebugMode && (currentToken?.startsWith('debug_') ?? false);

          if (isDebugToken && (statusCode == 401 || statusCode == 403)) {
            handler.next(error);
            return;
          }

          if (statusCode == 401 && !alreadyRetried && !isRefreshCall) {
            final refreshed = await _tryRefreshTokens();

            if (refreshed != null) {
              final retryOptions = Options(
                method: requestOptions.method,
                headers: Map<String, dynamic>.from(requestOptions.headers)
                  ..['Authorization'] = 'Bearer ${refreshed.accessToken}',
                responseType: requestOptions.responseType,
                contentType: requestOptions.contentType,
                sendTimeout: requestOptions.sendTimeout,
                receiveTimeout: requestOptions.receiveTimeout,
                extra: Map<String, dynamic>.from(requestOptions.extra)
                  ..['retried'] = true,
              );

              try {
                final retryResponse = await _dio.request<dynamic>(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: retryOptions,
                );
                handler.resolve(retryResponse);
                return;
              } on DioException catch (retryError) {
                handler.next(retryError);
                return;
              }
            }

            await _tokenStorage.clearAll();
            _unauthorizedHandler?.call();
          }

          handler.next(error);
        },
      ),
    );
  }

  void setRefreshTokensFn(RefreshTokensFn fn) {
    _refreshTokensFn = fn;
  }

  void setUnauthorizedHandler(void Function() fn) {
    _unauthorizedHandler = fn;
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<RefreshTokensResult?> _tryRefreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final fn = _refreshTokensFn;

    if (refreshToken == null || refreshToken.isEmpty || fn == null) {
      return null;
    }

    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    _refreshFuture = fn(refreshToken);

    try {
      final result = await _refreshFuture;
      if (result == null) return null;

      await _tokenStorage.saveAccessToken(result.accessToken);

      final nextRefreshToken = result.refreshToken;
      if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
        await _tokenStorage.saveRefreshToken(nextRefreshToken);
      }

      return result;
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }
}
