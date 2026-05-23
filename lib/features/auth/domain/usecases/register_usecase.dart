import 'package:diplomeprojectmobile/features/auth/domain/repos/auth_repo.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);

  final AuthRepo _repo;

  Future<void> call({
    required String email,
    required String password,
    required String role,
    String? shopName,
  }) {
    return _repo.register(
      email: email,
      password: password,
      role: role,
      shopName: shopName,
    );
  }
}
