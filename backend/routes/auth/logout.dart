import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

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
    final sessionId = jwt.payload['sid'].toString();

    final sessionStore = SessionStore();
    await sessionStore.deleteRefreshSession(sessionId);

    return Response.json(body: {'ok': true});
  } catch (_) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Invalid refresh token'},
    );
  }
}
