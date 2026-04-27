import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT
          unit_id,
          name,
          short_name
        FROM measurement_units
        ORDER BY unit_id DESC
        ''',
      );

      return Response.json(
        body: {
          'items': rows
              .map(
                (row) => {
                  'unit_id': row[0],
                  'name': row[1],
                  'short_name': row[2],
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
          as Map<String, dynamic>;

      final name = _toStringValue(data['name']);
      final shortName = _toStringValue(data['short_name']);

      if (name.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'name is required'},
        );
      }

      if (shortName.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'short_name is required'},
        );
      }

      final existing = await conn.execute(
        '''
        SELECT unit_id
        FROM measurement_units
        WHERE LOWER(name) = LOWER(\$1)
           OR LOWER(short_name) = LOWER(\$2)
        LIMIT 1
        ''',
        parameters: [name, shortName],
      );

      if (existing.isNotEmpty) {
        return Response.json(
          statusCode: 409,
          body: {'error': 'Measurement unit already exists'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO measurement_units (name, short_name)
        VALUES (\$1, \$2)
        RETURNING unit_id, name, short_name
        ''',
        parameters: [name, shortName],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'unit_id': row[0],
          'name': row[1],
          'short_name': row[2],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
