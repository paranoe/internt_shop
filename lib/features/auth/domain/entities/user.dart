class User {
  const User({
    required this.userId,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.patronymic,
    this.phone,
    this.gender,
    this.createdAt,
  });

  final int userId;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? patronymic;
  final String? phone;
  final String? gender;
  final DateTime? createdAt;
}
