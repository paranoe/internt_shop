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

  Future<void> register({
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

    await _dioClient.dio.post(ApiEndpoints.register, data: body);
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _dioClient.dio.post(
      '/auth/verify-email',
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resendVerificationCode({required String email}) async {
    await _dioClient.dio.post(
      '/auth/resend-verification-code',
      data: {'email': email},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _dioClient.dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dioClient.dio.post(
      '/auth/reset-password',
      data: {'email': email, 'code': code, 'new_password': newPassword},
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
