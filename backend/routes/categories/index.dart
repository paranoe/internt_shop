import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT category_id, name
    FROM categories
    ORDER BY name ASC
    ''',
  );

  final items = rows.map((r) => {'category_id': r[0], 'name': r[1]}).toList();

  return Response.json(body: {'items': items});
}




