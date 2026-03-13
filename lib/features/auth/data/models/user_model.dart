import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.email,
    required super.role,
    super.firstName,
    super.lastName,
    super.patronymic,
    super.phone,
    super.gender,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: int.parse(json['user_id'].toString()),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      patronymic: json['patronymic']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
