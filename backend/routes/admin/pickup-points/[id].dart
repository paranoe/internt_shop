import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<Response> onRequest(RequestContext context, String id) async {
  final pickupPointId = int.tryParse(id);
  if (pickupPointId == null || pickupPointId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid pickup point id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final cityId = _toInt(data['city_id']);

    if (cityId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'city_id is required'},
      );
    }

    final cityRows = await conn.execute(
      '''
      SELECT city_id, city_name
      FROM cities
      WHERE city_id = \$1
      LIMIT 1
      ''',
      parameters: [cityId],
    );

    if (cityRows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'City not found'},
      );
    }

    final updated = await conn.execute(
      '''
      UPDATE pickup_points
      SET city_id = \$1
      WHERE pickup_point_id = \$2
      RETURNING pickup_point_id, city_id
      ''',
      parameters: [cityId, pickupPointId],
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Pickup point not found'},
      );
    }

    final row = updated.first;
    final cityName = cityRows.first[1];

    return Response.json(
      body: {
        'pickup_point_id': row[0],
        'city_id': row[1],
        'city_name': cityName,
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM pickup_points
      WHERE pickup_point_id = \$1
      RETURNING pickup_point_id
      ''',
      parameters: [pickupPointId],
    );

    if (deleted.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Pickup point not found'},
      );
    }

    return Response.json(
      body: {
        'deleted': true,
        'pickup_point_id': pickupPointId,
      },
    );
  }

  return Response(statusCode: 405);
}
