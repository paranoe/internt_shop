import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT
          upp.user_pickup_id,
          pp.pickup_point_id,
          pp.city_id,
          c.city_name
        FROM user_pickup_points upp
        JOIN pickup_points pp ON pp.pickup_point_id = upp.pickup_point_id
        JOIN cities c ON c.city_id = pp.city_id
        WHERE upp.user_id = \$1
        ORDER BY upp.user_pickup_id DESC
        ''',
        parameters: [user.userId],
      );

      return Response.json(
        body: {
          'items': rows
              .map(
                (row) => {
                  'user_pickup_id': row[0],
                  'pickup_point_id': row[1],
                  'city_id': row[2],
                  'city_name': row[3],
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final pickupPointIdRaw = data['pickup_point_id'];
      final pickupPointId = pickupPointIdRaw is int
          ? pickupPointIdRaw
          : int.tryParse(pickupPointIdRaw.toString());

      if (pickupPointId == null) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'pickup_point_id is required'},
        );
      }

      final pickupExists = await conn.execute(
        '''
        SELECT pickup_point_id, city_id
        FROM pickup_points
        WHERE pickup_point_id = \$1
        ''',
        parameters: [pickupPointId],
      );

      if (pickupExists.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Pickup point not found'},
        );
      }

      final duplicate = await conn.execute(
        '''
        SELECT user_pickup_id
        FROM user_pickup_points
        WHERE user_id = \$1 AND pickup_point_id = \$2
        LIMIT 1
        ''',
        parameters: [user.userId, pickupPointId],
      );

      if (duplicate.isNotEmpty) {
        return Response.json(
          statusCode: 409,
          body: {'error': 'Pickup point already saved'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO user_pickup_points (user_id, pickup_point_id)
        VALUES (\$1, \$2)
        RETURNING user_pickup_id, pickup_point_id
        ''',
        parameters: [user.userId, pickupPointId],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'user_pickup_id': row[0],
          'pickup_point_id': row[1],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
