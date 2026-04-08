import 'package:dart_frog/dart_frog.dart';

import '../../lib/src/core/middleware/auth_roles_mw.dart';

Handler middleware(Handler handler) {
  return handler.use(requireAuthRoles(['buyer']));
}
