import 'package:diplomeprojectmobile/features/auth/domain/entities/auth_tokens.dart';
import 'package:diplomeprojectmobile/features/auth/domain/repos/auth_repo.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);

  final AuthRepo _repo;

  Future<AuthTokens> call({required String email, required String password}) {
    return _repo.login(email: email, password: password);
  }
}
