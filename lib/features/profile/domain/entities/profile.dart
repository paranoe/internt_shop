class ProfileEntity {
  const ProfileEntity({
    required this.userId,
    this.firstName,
    this.lastName,
    this.patronymic,
    this.phone,
    required this.email,
    this.gender,
    this.createdAt,
    required this.role,
  });

  final int userId;
  final String? firstName;
  final String? lastName;
  final String? patronymic;
  final String? phone;
  final String email;
  final String? gender;
  final String? createdAt;
  final String role;
}
