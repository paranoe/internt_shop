import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/password_hasher.dart';
import 'package:backend/src/core/security/jwt_service.dart';
import 'package:backend/src/core/security/refresh_token_service.dart';
import 'package:backend/src/integrations/redis/session_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();

  final raw = await context.request.body();
  final data = jsonDecode(raw) as Map<String, dynamic>;

  final email = data['email'] as String?;
  final password = data['password'] as String?;

  if (email == null || email.isEmpty || password == null || password.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Email and password required'},
    );
  }

  final conn = await db.connection;

  final rows = await conn.execute(
    '''
  SELECT u.user_id, u.password_hash, r.name
  FROM users u
  JOIN roles r ON r.role_id = u.role_id
  WHERE u.email = \$1
  LIMIT 1
  ''',
    parameters: [email],
  );

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Invalid credentials'},
    );
  }

  final row = rows.first;
  final userId = row[0] as int;
  final passwordHash = row[1] as String;
  final role = row[2] as String;

  if (!PasswordHasher.verify(password, passwordHash)) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Invalid credentials'},
    );
  }

  final token = JwtService.generateAccessToken(
    userId: userId,
    role: role,
  );
  final refresh = RefreshTokenService.generate(
    userId: userId,
    role: role,
  );

  final sessionStore = SessionStore();
  await sessionStore.saveRefreshSession(
    sessionId: refresh.sessionId,
    userId: userId,
    role: role,
  );
  return Response.json(
    body: {
      'access_token': token,
      'refresh_token': refresh.token,
      'user_id': userId,
      'role': role,
    },
  );
}
