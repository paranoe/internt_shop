import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';

import '../security/jwt_service.dart';
import 'package:backend/src/core/security/auth_user.dart';

Middleware requireAuthRoles(List<String> allowedRoles) {
  final allowed = allowedRoles.map((e) => e.toLowerCase()).toSet();

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

        final sub = payload['sub'];
        final role = (payload['role'] ?? '').toString().toLowerCase();

        if (sub == null || role.isEmpty) {
          return Response.json(
              statusCode: 401, body: {'error': 'Invalid token'});
        }

        final userId = (sub is int) ? sub : int.parse(sub.toString());
        final user = AuthUser(userId: userId, role: role);

        if (!allowed.contains(role)) {
          return Response.json(
            statusCode: 403,
            body: {
              'error': 'Forbidden',
              'role': role,
              'required': allowedRoles
            },
          );
        }

        return handler(context.provide<AuthUser>(() => user));
      } catch (_) {
        return Response.json(statusCode: 401, body: {'error': 'Invalid token'});
      }
    };
  };
}





