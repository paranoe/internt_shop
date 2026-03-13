import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/middleware/auth_mw.dart';
import 'package:backend/src/core/middleware/roles_mw.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requireRoles(['buyer']))
      .use(authMiddleware());
}
