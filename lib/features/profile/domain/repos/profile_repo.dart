import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';

abstract class ProfileRepo {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  });
}
