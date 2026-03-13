import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:backend/src/config/env.dart';

class JwtService {
  static final _env = Env.load();
  static final _secret = _env.get('JWT_SECRET');

  static String generateAccessToken({
    required int userId,
    required String role,
  }) {
    final jwt = JWT({
      'sub': userId,
      'role': role,
    });

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: const Duration(hours: 2),
    );
  }

  static JWT verify(String token) {
    return JWT.verify(token, SecretKey(_secret));
  }
}




