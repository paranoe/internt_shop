import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<Response> onRequest(RequestContext context, String id) async {
  final unitId = int.tryParse(id);
  if (unitId == null || unitId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid unit id'},
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

      if (data.containsKey('name')) {
        final name = _toStringValue(data['name']);
        if (name.isEmpty) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'name cannot be empty'},
          );
        }

        updates.add('name = \$$index');
        parameters.add(name);
        index++;
      }

      if (data.containsKey('short_name')) {
        final shortName = _toStringValue(data['short_name']);
        if (shortName.isEmpty) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'short_name cannot be empty'},
          );
        }

        updates.add('short_name = \$$index');
        parameters.add(shortName);
        index++;
      }

      if (updates.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'No fields to update'},
        );
      }

      parameters.add(unitId);

      final updated = await conn.execute(
        '''
        UPDATE measurement_units
        SET ${updates.join(', ')}
        WHERE unit_id = \$$index
        RETURNING unit_id, name, short_name
        ''',
        parameters: parameters,
      );

      if (updated.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Measurement unit not found'},
        );
      }

      final row = updated.first;

      return Response.json(
        body: {
          'unit_id': row[0],
          'name': row[1],
          'short_name': row[2],
        },
      );

    case HttpMethod.delete:
      final deleted = await conn.execute(
        '''
        DELETE FROM measurement_units
        WHERE unit_id = \$1
        RETURNING unit_id
        ''',
        parameters: [unitId],
      );

      if (deleted.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Measurement unit not found'},
        );
      }

      return Response.json(
        body: {
          'deleted': true,
          'unit_id': unitId,
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
