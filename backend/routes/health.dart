import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<PostgresClient>();
  try {
    final conn = await db.connection;
    await conn.execute('SELECT 1');
    return Response.json(body: {'status': 'ok', 'db': 'ok'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'status': 'error', 'db': 'fail', 'message': e.toString()},
    );
  }
}





