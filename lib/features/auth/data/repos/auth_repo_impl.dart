import 'package:diplomeprojectmobile/features/auth/data/datasources/auth_api.dart';
import 'package:diplomeprojectmobile/features/auth/domain/entities/auth_tokens.dart';
import 'package:diplomeprojectmobile/features/auth/domain/entities/user.dart';
import 'package:diplomeprojectmobile/features/auth/domain/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  const AuthRepoImpl(this._authApi);

  final AuthApi _authApi;

  @override
  Future<AuthTokens> login({required String email, required String password}) {
    return _authApi.login(email: email, password: password);
  }

  @override
  Future<AuthTokens> register({
    required String email,
    required String password,
    required String role,
    String? shopName,
  }) {
    return _authApi.register(
      email: email,
      password: password,
      role: role,
      shopName: shopName,
    );
  }

  @override
  Future<String> refreshSession({required String refreshToken}) {
    return _authApi.refreshSession(refreshToken: refreshToken);
  }

  @override
  Future<void> logout({required String refreshToken}) {
    return _authApi.logout(refreshToken: refreshToken);
  }

  @override
  Future<User> getMe() {
    return _authApi.getMe();
  }
}
