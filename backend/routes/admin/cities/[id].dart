import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<Response> onRequest(RequestContext context, String id) async {
  final cityId = int.tryParse(id);
  if (cityId == null || cityId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid city id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final cityName = _toStringValue(data['city_name']);

    if (cityName.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'city_name is required'},
      );
    }

    final duplicate = await conn.execute(
      '''
      SELECT city_id
      FROM cities
      WHERE LOWER(city_name) = LOWER(\$1)
        AND city_id <> \$2
      LIMIT 1
      ''',
      parameters: [cityName, cityId],
    );

    if (duplicate.length > 0) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'City with this name already exists'},
      );
    }

    final updated = await conn.execute(
      '''
      UPDATE cities
      SET city_name = \$1
      WHERE city_id = \$2
      RETURNING city_id, city_name
      ''',
      parameters: [cityName, cityId],
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'City not found'},
      );
    }

    final row = updated.first;

    return Response.json(
      body: {
        'city_id': row[0],
        'city_name': row[1],
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM cities
      WHERE city_id = \$1
      RETURNING city_id
      ''',
      parameters: [cityId],
    );

    if (deleted.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'City not found'},
      );
    }

    return Response.json(
      body: {
        'deleted': true,
        'city_id': cityId,
      },
    );
  }

  return Response(statusCode: 405);
}
