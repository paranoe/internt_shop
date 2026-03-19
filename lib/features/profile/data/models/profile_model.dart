import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    super.firstName,
    super.lastName,
    super.patronymic,
    super.phone,
    required super.email,
    super.gender,
    super.createdAt,
    required super.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      patronymic: json['patronymic']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      createdAt: json['created_at']?.toString(),
      role: json['role']?.toString() ?? '',
    );
  }
}
