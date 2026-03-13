import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';
import '../api_endpoints.dart';

class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({required Dio dio, required SecureStorage secureStorage})
    : _dio = dio,
      _secureStorage = secureStorage;

  final Dio _dio;
  final SecureStorage _secureStorage;

  bool _isRefreshing = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    final isUnauthorized = statusCode == 401;
    final isAuthRequest =
        path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refresh);

    if (!isUnauthorized || isAuthRequest || _isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _secureStorage.clearTokens();
        _isRefreshing = false;
        return handler.next(err);
      }

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {}),
      );

      final newAccessToken = response.data['access_token']?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _secureStorage.clearTokens();
        _isRefreshing = false;
        return handler.next(err);
      }

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final clonedResponse = await _dio.fetch(requestOptions);

      _isRefreshing = false;
      return handler.resolve(clonedResponse);
    } catch (_) {
      await _secureStorage.clearTokens();
      _isRefreshing = false;
      return handler.next(err);
    }
  }
}
