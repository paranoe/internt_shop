import 'package:diplomeprojectmobile/features/auth/domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.userId,
    required super.role,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      userId: int.parse(json['user_id'].toString()),
      role: json['role']?.toString() ?? '',
    );
  }
}
