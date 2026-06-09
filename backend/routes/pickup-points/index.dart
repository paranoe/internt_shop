import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final qp = context.request.uri.queryParameters;

  final cityId = int.tryParse(qp['city_id'] ?? '');
  final streetId = int.tryParse(qp['street_id'] ?? '');
  final houseId = int.tryParse(qp['house_id'] ?? '');

  final where = <String>[];
  final params = <Object?>[];

  if (cityId != null && cityId > 0) {
    where.add('c.city_id = \$${params.length + 1}');
    params.add(cityId);
  }

  if (streetId != null && streetId > 0) {
    where.add('s.street_id = \$${params.length + 1}');
    params.add(streetId);
  }

  if (houseId != null && houseId > 0) {
    where.add('h.house_id = \$${params.length + 1}');
    params.add(houseId);
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final rows = await conn.execute(
    '''
    SELECT
      pp.pickup_point_id,
      pp.house_id,
      h.house_number,
      s.street_id,
      s.street_name,
      c.city_id,
      c.city_name
    FROM pickup_points pp
    JOIN houses h ON h.house_id = pp.house_id
    JOIN streets s ON s.street_id = h.street_id
    JOIN cities c ON c.city_id = s.city_id
    $whereSql
    ORDER BY c.city_name ASC, s.street_name ASC, h.house_number ASC
    ''',
    parameters: params,
  );

  final items = rows.map((row) {
    final streetName = row[4]?.toString() ?? '';
    final houseNumber = row[2]?.toString() ?? '';
    final cityName = row[6]?.toString() ?? '';

    final address = 'ул. $streetName, д. $houseNumber, $cityName';

    return {
      'pickup_point_id': row[0],
      'house_id': row[1],
      'house_number': row[2],
      'street_id': row[3],
      'street_name': row[4],
      'city_id': row[5],
      'city_name': row[6],
      'address': address,
      'display_name': address,
    };
  }).toList();

  return Response.json(body: {'items': items});
}
