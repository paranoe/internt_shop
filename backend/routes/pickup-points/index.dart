import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final qp = context.request.uri.queryParameters;
  final cityId = int.tryParse(qp['city_id'] ?? '');

  final where = <String>[];
  final params = <Object?>[];

  if (cityId != null) {
    where.add('pp.city_id = \$${params.length + 1}');
    params.add(cityId);
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final rows = await conn.execute(
    '''
    SELECT
      pp.pickup_point_id,
      pp.city_id,
      c.city_name
    FROM pickup_points pp
    JOIN cities c ON c.city_id = pp.city_id
    $whereSql
    ORDER BY c.city_name ASC, pp.pickup_point_id ASC
    ''',
    parameters: params,
  );

  final items = rows.map((r) {
    return {
      'pickup_point_id': r[0],
      'city_id': r[1],
      'city_name': r[2],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
