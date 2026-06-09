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

Future<Response> onRequest(RequestContext context, String id) async {
  final pickupPointId = int.tryParse(id);

  if (pickupPointId == null || pickupPointId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid pickup point id'},
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, pickupPointId);
    case HttpMethod.patch:
      return _patch(context, pickupPointId);
    case HttpMethod.delete:
      return _delete(context, pickupPointId);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _get(RequestContext context, int pickupPointId) async {
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
    WHERE pp.pickup_point_id = \$1
    LIMIT 1
    ''',
    parameters: [pickupPointId],
  );

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Pickup point not found'},
    );
  }

  return Response.json(body: _pickupPointFromRow(rows.first));
}

Future<Response> _patch(RequestContext context, int pickupPointId) async {
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

  final updated = await conn.execute(
    '''
    UPDATE pickup_points
    SET house_id = \$1
    WHERE pickup_point_id = \$2
    RETURNING pickup_point_id
    ''',
    parameters: [houseId, pickupPointId],
  );

  if (updated.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Pickup point not found'},
    );
  }

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

  return Response.json(body: _pickupPointFromRow(rows.first));
}

Future<Response> _delete(RequestContext context, int pickupPointId) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final deleted = await conn.execute(
    '''
    DELETE FROM pickup_points
    WHERE pickup_point_id = \$1
    RETURNING pickup_point_id
    ''',
    parameters: [pickupPointId],
  );

  if (deleted.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Pickup point not found'},
    );
  }

  return Response.json(body: {'ok': true});
}
