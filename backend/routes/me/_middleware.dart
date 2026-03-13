import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/middleware/auth_mw.dart';

Handler middleware(Handler handler) {
  return handler.use(authMiddleware());
}
