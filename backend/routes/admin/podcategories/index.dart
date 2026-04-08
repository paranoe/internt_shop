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

  if (context.request.method == HttpMethod.get) {
    final qp = context.request.uri.queryParameters;
    final q = _toStringValue(qp['q']);
    final categoryId = int.tryParse((qp['category_id'] ?? '').trim());

    final where = <String>[];
    final params = <Object?>[];

    if (q.isNotEmpty) {
      where.add('p.name ILIKE \$${params.length + 1}');
      params.add('%$q%');
    }

    if (categoryId != null && categoryId > 0) {
      where.add('p.category_id = \$${params.length + 1}');
      params.add(categoryId);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final rows = await conn.execute(
      '''
  SELECT
    p.podcategories_id,
    p.name,
    p.category_id,
    c.name
  FROM podcategories p
  JOIN categories c
    ON c.category_id = p.category_id
  $whereSql
  ORDER BY p.name ASC, p.podcategories_id ASC
  ''',
      parameters: params,
    );

    final items = rows
        .map(
          (r) => {
            'subcategory_id': r[0],
            'name': r[1],
            'category_id': r[2],
            'category_name': r[3],
          },
        )
        .toList();

    return Response.json(body: {'items': items});
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final name = _toStringValue(data['name']);
    final categoryId = _toInt(data['category_id']);

    if (name.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'name is required'},
      );
    }

    if (categoryId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'category_id is required'},
      );
    }

    final categoryRows = await conn.execute(
      '''
  SELECT category_id, name
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

    final inserted = await conn.execute(
      '''
      INSERT INTO podcategories (name, category_id)
      VALUES (\$1, \$2)
      RETURNING podcategories_id, name, category_id
      ''',
      parameters: [name, categoryId],
    );

    final row = inserted.first;

    return Response.json(
      statusCode: 201,
      body: {
        'subcategory_id': row[0],
        'name': row[1],
        'category_id': row[2],
        'category_name': categoryRows.first[1],
      },
    );
  }

  return Response(statusCode: 405);
}
