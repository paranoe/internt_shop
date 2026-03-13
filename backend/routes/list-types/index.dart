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
    SELECT list_type_id, list_type_name
    FROM list_types
    ORDER BY list_type_id ASC
    ''',
  );

  final items = rows.map((r) {
    return {
      'list_type_id': r[0],
      'list_type_name': r[1],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
