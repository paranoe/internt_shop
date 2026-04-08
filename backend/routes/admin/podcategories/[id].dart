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
  final subcategoryId = int.tryParse(id);
  if (subcategoryId == null || subcategoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid subcategory id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final updates = <String>[];
    final params = <Object?>[];
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
      params.add(name);
      index++;
    }

    if (data.containsKey('category_id')) {
      final categoryId = _toInt(data['category_id']);
      if (categoryId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'category_id must be valid'},
        );
      }

      final categoryRows = await conn.execute(
        '''
        SELECT category_id
        FROM categories
        WHERE category_id = \$1
        LIMIT 1
        ''',
        parameters: [categoryId],
      );

      if (categoryRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Category not found'},
        );
      }

      updates.add('category_id = \$$index');
      params.add(categoryId);
      index++;
    }

    if (updates.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'No fields to update'},
      );
    }

    params.add(subcategoryId);
    final subcategoryPos = index;

    final updated = await conn.execute(
      '''
      UPDATE podcategories
      SET ${updates.join(', ')}
      WHERE podcategories_id = \$$subcategoryPos
      RETURNING podcategories_id, name, category_id
      ''',
      parameters: params,
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Subcategory not found'},
      );
    }

    final row = updated.first;

    return Response.json(
      body: {
        'subcategory_id': row[0],
        'name': row[1],
        'category_id': row[2],
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM podcategories
      WHERE podcategories_id = \$1
      RETURNING podcategories_id
      ''',
      parameters: [subcategoryId],
    );

    if (deleted.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Subcategory not found'},
      );
    }

    return Response.json(
      body: {
        'deleted': true,
        'subcategory_id': subcategoryId,
      },
    );
  }

  return Response(statusCode: 405);
}
