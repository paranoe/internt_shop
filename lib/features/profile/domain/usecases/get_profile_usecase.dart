import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';
import 'package:diplomeprojectmobile/features/profile/domain/repos/profile_repo.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repo);

  final ProfileRepo _repo;

  Future<ProfileEntity> call() => _repo.getProfile();
}
