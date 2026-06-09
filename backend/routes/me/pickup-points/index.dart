import 'dart:convert';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;
  print('!!!!!!!!!!!! REAL /ME/PICKUP-POINTS ROUTE USED !!!!!!!!!!!!');
  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT
          upp.user_pickup_id,
          upp.user_id,
          upp.pickup_point_id,
          pp.house_id,
          h.house_number,
          s.street_id,
          s.street_name,
          c.city_id,
          c.city_name
        FROM user_pickup_points upp
        JOIN pickup_points pp ON pp.pickup_point_id = upp.pickup_point_id
        JOIN houses h ON h.house_id = pp.house_id
        JOIN streets s ON s.street_id = h.street_id
        JOIN cities c ON c.city_id = s.city_id
        WHERE upp.user_id = \$1
        ORDER BY upp.user_pickup_id DESC
        ''',
        parameters: [auth.userId],
      );

      final items = rows.map((row) {
        final streetName = row[6]?.toString() ?? '';
        final houseNumber = row[4]?.toString() ?? '';
        final cityName = row[8]?.toString() ?? '';

        final address = 'ул. $streetName, д. $houseNumber, $cityName';

        return {
          'debug_source': 'ONLY_USER_PICKUP_POINTS',
          'debug_auth_user_id': auth.userId,
          'user_pickup_id': row[0],
          'id': row[0],
          'user_id': row[1],
          'pickup_point_id': row[2],
          'house_id': row[3],
          'house_number': row[4],
          'street_id': row[5],
          'street_name': row[6],
          'city_id': row[7],
          'city_name': row[8],
          'address': address,
          'display_name': address,
        };
      }).toList();

      return Response.json(
        body: {
          'debug_source': 'ONLY_USER_PICKUP_POINTS',
          'debug_auth_user_id': auth.userId,
          'count': items.length,
          'items': items,
        },
      );

    case HttpMethod.post:
      final rawBody = await context.request.body();

      if (rawBody.trim().isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'Request body is empty'},
        );
      }

      final data = jsonDecode(rawBody) as Map<String, dynamic>;
      final pickupPointId = _toInt(data['pickup_point_id']);

      if (pickupPointId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'pickup_point_id is required'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO user_pickup_points (user_id, pickup_point_id)
        SELECT \$1, \$2
        WHERE EXISTS (
          SELECT 1
          FROM pickup_points
          WHERE pickup_point_id = \$2
        )
        RETURNING user_pickup_id, user_id, pickup_point_id
        ''',
        parameters: [auth.userId, pickupPointId],
      );

      if (inserted.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Pickup point not found'},
        );
      }

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'user_pickup_id': row[0],
          'id': row[0],
          'user_id': row[1],
          'pickup_point_id': row[2],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
