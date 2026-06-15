import 'package:diplomeprojectmobile/features/profile/data/datasources/profile_api.dart';
import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';
import 'package:diplomeprojectmobile/features/profile/domain/repos/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  const ProfileRepoImpl(this._api);

  final ProfileApi _api;

  @override
  Future<ProfileEntity> getProfile() => _api.getProfile();

  @override
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  }) {
    return _api.updateProfile(
      firstName: firstName,
      lastName: lastName,
      patronymic: patronymic,
      phone: phone,
      gender: gender,
    );
  }
}