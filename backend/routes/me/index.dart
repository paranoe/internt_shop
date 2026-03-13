import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/middleware/auth_roles_mw.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT user_id, first_name, last_name, patronymic,
           phone, email, gender, created_at
    FROM users
    WHERE user_id = \$1
    ''',
    parameters: [auth.userId],
  );

  if (rows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'User not found'});
  }

  final r = rows.first;

  return Response.json(body: {
    'user_id': r[0],
    'first_name': r[1],
    'last_name': r[2],
    'patronymic': r[3],
    'phone': r[4],
    'email': r[5],
    'gender': r[6],
    'created_at': r[7].toString(),
    'role': auth.role,
  });
}




