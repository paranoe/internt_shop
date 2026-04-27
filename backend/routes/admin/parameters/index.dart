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
          p.parameter_id,
          p.name,
          p.data_type,
          p.unit_id,
          mu.name,
          mu.short_name
        FROM parameters p
        LEFT JOIN measurement_units mu
          ON mu.unit_id = p.unit_id
        ORDER BY p.parameter_id DESC
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
                  'unit_id': row[3],
                  'unit_name': row[4],
                  'unit_short_name': row[5],
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
      final unitId = data['unit_id'] == null ? null : _toInt(data['unit_id']);

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

      if (dataType != 'number' && unitId != null && unitId > 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'unit_id is allowed only for number type'},
        );
      }

      if (unitId != null && unitId > 0) {
        final unitRows = await conn.execute(
          '''
          SELECT unit_id
          FROM measurement_units
          WHERE unit_id = \$1
          LIMIT 1
          ''',
          parameters: [unitId],
        );

        if (unitRows.length == 0) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Measurement unit not found'},
          );
        }
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
        INSERT INTO parameters (name, data_type, unit_id)
        VALUES (\$1, \$2, \$3)
        RETURNING parameter_id, name, data_type, unit_id
        ''',
        parameters: [
          name,
          dataType,
          (unitId != null && unitId > 0) ? unitId : null,
        ],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'parameter_id': row[0],
          'name': row[1],
          'data_type': row[2],
          'unit_id': row[3],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
