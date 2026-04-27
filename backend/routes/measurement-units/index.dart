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
    SELECT
      unit_id,
      name,
      short_name
    FROM measurement_units
    ORDER BY name ASC, unit_id ASC
    ''',
  );

  final items = rows.map((r) {
    return {
      'unit_id': r[0],
      'name': r[1],
      'short_name': r[2],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
