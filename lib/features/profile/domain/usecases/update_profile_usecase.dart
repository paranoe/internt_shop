import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';
import 'package:diplomeprojectmobile/features/profile/domain/repos/profile_repo.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repo);

  final ProfileRepo _repo;

  Future<ProfileEntity> call({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  }) {
    return _repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      patronymic: patronymic,
      phone: phone,
      gender: gender,
    );
  }
}
