import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<Response> onRequest(RequestContext context, String id) async {
  final categoryId = int.tryParse(id);
  if (categoryId == null || categoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid category id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final categoryName = _toStringValue(
      data['category_name'] ?? data['name'],
    );

    if (categoryName.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'category_name is required'},
      );
    }

    final duplicate = await conn.execute(
      '''
      SELECT category_id
      FROM categories
      WHERE LOWER(name) = LOWER(\$1)
        AND category_id <> \$2
      LIMIT 1
      ''',
      parameters: [categoryName, categoryId],
    );

    if (duplicate.length > 0) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'Category with this name already exists'},
      );
    }

    final updated = await conn.execute(
      '''
      UPDATE categories
      SET name = \$1
      WHERE category_id = \$2
      RETURNING category_id, name
      ''',
      parameters: [categoryName, categoryId],
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Category not found'},
      );
    }

    final row = updated.first;

    return Response.json(
      body: {
        'category_id': row[0],
        'category_name': row[1],
        'name': row[1],
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM categories
      WHERE category_id = \$1
      RETURNING category_id
      ''',
      parameters: [categoryId],
    );

    if (deleted.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Category not found'},
      );
    }

    return Response.json(
      body: {
        'deleted': true,
        'category_id': categoryId,
      },
    );
  }

  return Response(statusCode: 405);
}
