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

  final streetId = int.tryParse(
    context.request.uri.queryParameters['street_id'] ?? '',
  );

  if (streetId == null || streetId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'street_id is required'},
    );
  }

  final rows = await conn.execute(
    '''
    SELECT house_id, street_id, house_number
    FROM houses
    WHERE street_id = \$1
    ORDER BY house_number ASC
    ''',
    parameters: [streetId],
  );

  final items = rows.map((row) {
    return {
      'house_id': row[0],
      'street_id': row[1],
      'house_number': row[2],
    };
  }).toList();

  return Response.json(body: {'items': items});
}

Future<Response> _post(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final data = jsonDecode(await context.request.body()) as Map<String, dynamic>;

  final streetId = _toInt(data['street_id']);
  final houseNumber = data['house_number']?.toString().trim() ?? '';

  if (streetId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'street_id is required'},
    );
  }

  if (houseNumber.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'house_number is required'},
    );
  }

  final rows = await conn.execute(
    '''
    INSERT INTO houses (street_id, house_number)
    VALUES (\$1, \$2)
    RETURNING house_id, street_id, house_number
    ''',
    parameters: [streetId, houseNumber],
  );

  final row = rows.first;

  return Response.json(
    statusCode: 201,
    body: {
      'house_id': row[0],
      'street_id': row[1],
      'house_number': row[2],
    },
  );
}
