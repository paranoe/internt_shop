import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';

Middleware requireRoles(List<String> allowed) {
  final normalized = allowed.map((e) => e.toLowerCase()).toSet();

  return (handler) {
    return (context) async {
      final user =
          context.read<AuthUser>(); // authMiddleware должен сработать раньше
      final role = user.role.toLowerCase();

      if (!normalized.contains(role)) {
        return Response.json(statusCode: 403, body: {'error': 'Forbidden'});
      }

      return handler(context);
    };
  };
}
