import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/core/security/jwt_service.dart';
import 'package:backend/src/db/postgres_pool.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final auth = context.request.headers['authorization'];
      if (auth == null || !auth.toLowerCase().startsWith('bearer ')) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Unauthorized'},
        );
      }

      final token = auth.substring(7).trim();

      try {
        final jwt = JwtService.verify(token);
        final payload = jwt.payload;

        final userIdRaw = payload['sub'];
        final roleRaw = payload['role'];

        if (userIdRaw == null || roleRaw == null) {
          return Response.json(
            statusCode: 401,
            body: {'error': 'Invalid token'},
          );
        }

        final userId =
            userIdRaw is int ? userIdRaw : int.parse(userIdRaw.toString());
        final role = roleRaw.toString();

        final db = context.read<PostgresClient>();
        final conn = await db.connection;

        final rows = await conn.execute(
          '''
          SELECT COALESCE(is_blocked, false)
          FROM users
          WHERE user_id = \$1
          LIMIT 1
          ''',
          parameters: [userId],
        );

        if (rows.isEmpty) {
          return Response.json(
            statusCode: 401,
            body: {'error': 'User not found'},
          );
        }

        final isBlocked = rows.first[0] == true;
        if (isBlocked) {
          return Response.json(
            statusCode: 403,
            body: {'error': 'User is blocked'},
          );
        }

        final authed = AuthUser(userId: userId, role: role);

        return handler(context.provide<AuthUser>(() => authed));
      } catch (_) {
        return Response.json(
          statusCode: 401,
          body: {'error': 'Invalid token'},
        );
      }
    };
  };
}
