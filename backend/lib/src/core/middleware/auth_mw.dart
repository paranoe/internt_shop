import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/core/security/jwt_service.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final auth = context.request.headers['authorization'];
      if (auth == null || !auth.toLowerCase().startsWith('bearer ')) {
        return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
      }

      final token = auth.substring(7).trim();

      try {
        final jwt = JwtService.verify(token);
        final payload = jwt.payload;

        final userIdRaw = payload['sub'];
        final roleRaw = payload['role'];

        if (userIdRaw == null || roleRaw == null) {
          return Response.json(
              statusCode: 401, body: {'error': 'Invalid token'});
        }

        final userId =
            (userIdRaw is int) ? userIdRaw : int.parse(userIdRaw.toString());
        final role = roleRaw.toString();

        final authed = AuthUser(userId: userId, role: role);

        return handler(context.provide<AuthUser>(() => authed));
      } catch (_) {
        return Response.json(statusCode: 401, body: {'error': 'Invalid token'});
      }
    };
  };
}
