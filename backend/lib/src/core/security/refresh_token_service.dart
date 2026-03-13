import 'dart:convert';
import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class RefreshTokenService {
  static String _secret() {
    const fromDefine = String.fromEnvironment(
      'JWT_SECRET',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) return fromDefine;
    return const String.fromEnvironment(
      'JWT_SECRET',
      defaultValue: 'SUPER_SECRET_KEY_CHANGE_ME',
    );
  }

  static String _randomSessionId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static ({String token, String sessionId}) generate({
    required int userId,
    required String role,
  }) {
    final sessionId = _randomSessionId();

    final jwt = JWT({
      'sub': userId,
      'role': role,
      'sid': sessionId,
      'type': 'refresh',
    });

    final token = jwt.sign(
      SecretKey(_secret()),
      expiresIn: const Duration(days: 30),
    );

    return (token: token, sessionId: sessionId);
  }

  static JWT verify(String token) {
    return JWT.verify(token, SecretKey(_secret()));
  }
}
