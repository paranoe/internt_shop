import 'package:dio/dio.dart';
import 'package:diplomeprojectmobile/app/di/env.dart';
import 'package:diplomeprojectmobile/core/storage/secure_storage.dart';
import 'package:diplomeprojectmobile/core/network/interceptors/auth_interceptor.dart';
import 'package:diplomeprojectmobile/core/network/interceptors/refresh_interceptor.dart';

class DioClient {
  DioClient(this._secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(_secureStorage));
    dio.interceptors.add(
      RefreshInterceptor(dio: dio, secureStorage: _secureStorage),
    );
  }

  final SecureStorage _secureStorage;
  late final Dio dio;
}
