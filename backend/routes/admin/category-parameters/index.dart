import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT
          cp.podcategory_id,
          s.name AS subcategory_name,
          cp.parameter_id,
          p.name AS parameter_name,
          p.data_type,
          cp.is_required
        FROM category_parameters cp
        JOIN podcategories s
          ON s.podcategories_id = cp.podcategory_id
        JOIN parameters p
          ON p.parameter_id = cp.parameter_id
        ORDER BY s.name ASC, p.name ASC
        ''',
      );

      return Response.json(
        body: {
          'items': rows
              .map(
                (row) => {
                  'subcategory_id': row[0],
                  'subcategory_name': row[1],
                  'parameter_id': row[2],
                  'parameter_name': row[3],
                  'data_type': row[4],
                  'is_required': row[5],
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final subcategoryId = _toInt(data['subcategory_id']);
      final parameterId = _toInt(data['parameter_id']);
      final isRequired = data['is_required'] == true;

      if (subcategoryId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'subcategory_id is required'},
        );
      }

      if (parameterId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'parameter_id is required'},
        );
      }

      final subcategoryRows = await conn.execute(
        '''
        SELECT podcategories_id
        FROM podcategories
        WHERE podcategories_id = \$1
        LIMIT 1
        ''',
        parameters: [subcategoryId],
      );

      if (subcategoryRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Subcategory not found'},
        );
      }

      final parameterRows = await conn.execute(
        '''
        SELECT parameter_id
        FROM parameters
        WHERE parameter_id = \$1
        LIMIT 1
        ''',
        parameters: [parameterId],
      );

      if (parameterRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Parameter not found'},
        );
      }

      final existing = await conn.execute(
        '''
        SELECT 1
        FROM category_parameters
        WHERE podcategory_id = \$1
          AND parameter_id = \$2
        LIMIT 1
        ''',
        parameters: [subcategoryId, parameterId],
      );

      if (existing.length > 0) {
        return Response.json(
          statusCode: 409,
          body: {'error': 'Binding already exists'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO category_parameters (
          podcategory_id,
          parameter_id,
          is_required
        )
        VALUES (\$1, \$2, \$3)
        RETURNING podcategory_id, parameter_id, is_required
        ''',
        parameters: [subcategoryId, parameterId, isRequired],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'subcategory_id': row[0],
          'parameter_id': row[1],
          'is_required': row[2],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
