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

Future<Response> onRequest(RequestContext context, String id) async {
  final parameterId = int.tryParse(id);
  if (parameterId == null || parameterId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid parameter id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.patch:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final updates = <String>[];
      final parameters = <dynamic>[];
      var index = 1;

      String? nextDataType;
      int? nextUnitId;
      bool unitChanged = false;

      if (data.containsKey('name')) {
        final name = _toStringValue(data['name']);
        if (name.isEmpty) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'name cannot be empty'},
          );
        }

        final existing = await conn.execute(
          '''
          SELECT parameter_id
          FROM parameters
          WHERE LOWER(name) = LOWER(\$1)
            AND parameter_id <> \$2
          LIMIT 1
          ''',
          parameters: [name, parameterId],
        );

        if (existing.length > 0) {
          return Response.json(
            statusCode: 409,
            body: {'error': 'Parameter with this name already exists'},
          );
        }

        updates.add('name = \$$index');
        parameters.add(name);
        index++;
      }

      if (data.containsKey('data_type')) {
        final dataType = _toStringValue(data['data_type']);

        const allowedTypes = {'text', 'number', 'boolean'};
        if (!allowedTypes.contains(dataType)) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'data_type must be text, number or boolean'},
          );
        }

        nextDataType = dataType;
        updates.add('data_type = \$$index');
        parameters.add(dataType);
        index++;
      }

      if (data.containsKey('unit_id')) {
        unitChanged = true;
        nextUnitId = data['unit_id'] == null ? null : _toInt(data['unit_id']);

        if (nextUnitId != null && nextUnitId! > 0) {
          final unitRows = await conn.execute(
            '''
            SELECT unit_id
            FROM measurement_units
            WHERE unit_id = \$1
            LIMIT 1
            ''',
            parameters: [nextUnitId],
          );

          if (unitRows.length == 0) {
            return Response.json(
              statusCode: 404,
              body: {'error': 'Measurement unit not found'},
            );
          }
        }

        updates.add('unit_id = \$$index');
        parameters
            .add((nextUnitId != null && nextUnitId! > 0) ? nextUnitId : null);
        index++;
      }

      if (updates.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'No fields to update'},
        );
      }

      if (nextDataType != null) {
        final unitToCheck = unitChanged ? nextUnitId : null;
        if (nextDataType != 'number' &&
            unitToCheck != null &&
            unitToCheck > 0) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'unit_id is allowed only for number type'},
          );
        }

        if (nextDataType != 'number' && !unitChanged) {
          updates.add('unit_id = NULL');
        }
      }

      parameters.add(parameterId);

      final updated = await conn.execute(
        '''
        UPDATE parameters
        SET ${updates.join(', ')}
        WHERE parameter_id = \$$index
        RETURNING parameter_id, name, data_type, unit_id
        ''',
        parameters: parameters,
      );

      if (updated.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Parameter not found'},
        );
      }

      final row = updated.first;

      return Response.json(
        body: {
          'parameter_id': row[0],
          'name': row[1],
          'data_type': row[2],
          'unit_id': row[3],
        },
      );

    case HttpMethod.delete:
      final deleted = await conn.execute(
        '''
        DELETE FROM parameters
        WHERE parameter_id = \$1
        RETURNING parameter_id
        ''',
        parameters: [parameterId],
      );

      if (deleted.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Parameter not found'},
        );
      }

      return Response.json(
        body: {
          'deleted': true,
          'parameter_id': parameterId,
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
