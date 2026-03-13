class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final int userId;
  final String role;
}
