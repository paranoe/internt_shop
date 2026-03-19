import 'package:diplomeprojectmobile/features/profile/data/datasources/profile_api.dart';
import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';
import 'package:diplomeprojectmobile/features/profile/domain/repos/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  ProfileRepoImpl(this._profileApi);

  final ProfileApi _profileApi;

  @override
  Future<ProfileEntity> getProfile() async {
    return _profileApi.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  }) async {
    return _profileApi.updateProfile(
      firstName: firstName,
      lastName: lastName,
      patronymic: patronymic,
      phone: phone,
      gender: gender,
    );
  }
}
