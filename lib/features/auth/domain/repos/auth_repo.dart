import 'package:diplomeprojectmobile/features/auth/domain/entities/auth_tokens.dart';
import 'package:diplomeprojectmobile/features/auth/domain/entities/user.dart';

abstract class AuthRepo {
  Future<AuthTokens> login({required String email, required String password});

  Future<AuthTokens> register({
    required String email,
    required String password,
    required String role,
    String? shopName,
  });

  Future<String> refreshSession({required String refreshToken});

  Future<void> logout({required String refreshToken});

  Future<User> getMe();
}
