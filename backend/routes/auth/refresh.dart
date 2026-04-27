import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/jwt_service.dart';
import 'package:backend/src/core/security/refresh_token_service.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/integrations/redis/session_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final refreshToken = data['refresh_token']?.toString();
  if (refreshToken == null || refreshToken.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'refresh_token required'},
    );
  }

  try {
    final jwt = RefreshTokenService.verify(refreshToken);
    final payload = jwt.payload;

    final userId = int.parse(payload['sub'].toString());
    final role = payload['role'].toString();
    final sessionId = payload['sid'].toString();

    final sessionStore = SessionStore();
    final session = await sessionStore.getRefreshSession(sessionId);

    if (session == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Refresh session not found'},
      );
    }

    final db = context.read<PostgresClient>();
    final conn = await db.connection;

    final userRows = await conn.execute(
      '''
      SELECT COALESCE(is_blocked, false)
      FROM users
      WHERE user_id = \$1
      LIMIT 1
      ''',
      parameters: [userId],
    );

    if (userRows.isEmpty) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'User not found'},
      );
    }

    final isBlocked = userRows.first[0] == true;
    if (isBlocked) {
      await sessionStore.deleteRefreshSession(sessionId);
      return Response.json(
        statusCode: 403,
        body: {'error': 'User is blocked'},
      );
    }

    final accessToken = JwtService.generateAccessToken(
      userId: userId,
      role: role,
    );

    return Response.json(
      body: {'access_token': accessToken},
    );
  } catch (_) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Invalid refresh token'},
    );
  }
}
