import '../repos/auth_repo.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repo);

  final AuthRepo _repo;

  Future<String> call({required String refreshToken}) {
    return _repo.refreshSession(refreshToken: refreshToken);
  }
}
