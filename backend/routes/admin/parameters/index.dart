import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

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
          parameter_id,
          name,
          data_type
        FROM parameters
        ORDER BY parameter_id DESC
        ''',
      );

      return Response.json(
        body: {
          'items': rows
              .map(
                (row) => {
                  'parameter_id': row[0],
                  'name': row[1],
                  'data_type': row[2],
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final name = _toStringValue(data['name']);
      final dataType = _toStringValue(data['data_type']);

      if (name.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'name is required'},
        );
      }

      if (dataType.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'data_type is required'},
        );
      }

      const allowedTypes = {'text', 'number', 'boolean'};
      if (!allowedTypes.contains(dataType)) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'data_type must be text, number or boolean'},
        );
      }

      final existing = await conn.execute(
        '''
        SELECT parameter_id
        FROM parameters
        WHERE LOWER(name) = LOWER(\$1)
        LIMIT 1
        ''',
        parameters: [name],
      );

      if (existing.length > 0) {
        return Response.json(
          statusCode: 409,
          body: {'error': 'Parameter already exists'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO parameters (name, data_type)
        VALUES (\$1, \$2)
        RETURNING parameter_id, name, data_type
        ''',
        parameters: [name, dataType],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'parameter_id': row[0],
          'name': row[1],
          'data_type': row[2],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
