import 'dart:convert';

import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Map<String, dynamic> _pickupPointFromRow(dynamic row) {
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
}

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _get(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

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
    ORDER BY s.street_name ASC, h.house_number ASC, c.city_name ASC
    ''',
  );

  final items = rows.map(_pickupPointFromRow).toList();

  return Response.json(body: {'items': items});
}

Future<Response> _post(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final data = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  final houseId = _toInt(data['house_id']);

  if (houseId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'house_id is required'},
    );
  }

  final inserted = await conn.execute(
    '''
    INSERT INTO pickup_points (house_id)
    VALUES (\$1)
    RETURNING pickup_point_id
    ''',
    parameters: [houseId],
  );

  final pickupPointId = inserted.first[0];

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
    WHERE pp.pickup_point_id = \$1
    LIMIT 1
    ''',
    parameters: [pickupPointId],
  );

  return Response.json(
    statusCode: 201,
    body: _pickupPointFromRow(rows.first),
  );
}
