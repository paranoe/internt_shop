import '../repos/auth_repo.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repo);

  final AuthRepo _repo;

  Future<void> call({required String refreshToken}) {
    return _repo.logout(refreshToken: refreshToken);
  }
}
