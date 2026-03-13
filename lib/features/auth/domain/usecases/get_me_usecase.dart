import '../entities/user.dart';
import '../repos/auth_repo.dart';

class GetMeUseCase {
  const GetMeUseCase(this._repo);

  final AuthRepo _repo;

  Future<User> call() {
    return _repo.getMe();
  }
}
