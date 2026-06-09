import 'dart:convert';

import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
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

  final cityId = int.tryParse(
    context.request.uri.queryParameters['city_id'] ?? '',
  );

  if (cityId == null || cityId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'city_id is required'},
    );
  }

  final rows = await conn.execute(
    '''
    SELECT street_id, city_id, street_name
    FROM streets
    WHERE city_id = \$1
    ORDER BY street_name ASC
    ''',
    parameters: [cityId],
  );

  final items = rows.map((row) {
    return {
      'street_id': row[0],
      'city_id': row[1],
      'street_name': row[2],
    };
  }).toList();

  return Response.json(body: {'items': items});
}

Future<Response> _post(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final data = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final cityId = _toInt(data['city_id']);
  final streetName = data['street_name']?.toString().trim() ?? '';

  if (cityId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'city_id is required'},
    );
  }

  if (streetName.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'street_name is required'},
    );
  }

  final rows = await conn.execute(
    '''
    INSERT INTO streets (city_id, street_name)
    VALUES (\$1, \$2)
    RETURNING street_id, city_id, street_name
    ''',
    parameters: [cityId, streetName],
  );

  final row = rows.first;

  return Response.json(
    statusCode: 201,
    body: {
      'street_id': row[0],
      'city_id': row[1],
      'street_name': row[2],
    },
  );
}
