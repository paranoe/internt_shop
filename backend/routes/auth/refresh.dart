import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/jwt_service.dart';
import 'package:backend/src/core/security/refresh_token_service.dart';
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
