import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthApi {
  const AuthApi(this._dioClient);

  final DioClient _dioClient;

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return AuthTokensModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AuthTokensModel> register({
    required String email,
    required String password,
    required String role,
    String? shopName,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'role': role,
    };

    if (shopName != null && shopName.trim().isNotEmpty) {
      body['shop_name'] = shopName.trim();
    }

    final response = await _dioClient.dio.post(
      ApiEndpoints.register,
      data: body,
    );

    return AuthTokensModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<String> refreshSession({required String refreshToken}) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );

    return response.data['access_token'].toString();
  }

  Future<void> logout({required String refreshToken}) async {
    await _dioClient.dio.post(
      ApiEndpoints.logout,
      data: {'refresh_token': refreshToken},
    );
  }

  Future<UserModel> getMe() async {
    final response = await _dioClient.dio.get(ApiEndpoints.me);

    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
