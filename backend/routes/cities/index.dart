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
    SELECT city_id, city_name
    FROM cities
    ORDER BY city_name ASC, city_id ASC
    ''',
  );

  final items = rows.map((r) {
    return {
      'city_id': r[0],
      'city_name': r[1],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
