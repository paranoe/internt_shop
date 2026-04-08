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
    final page = _toInt(qp['page'], fallback: 1);
    final limit = _toInt(qp['limit'], fallback: 20);
    final q = _toStringValue(qp['q']);

    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
    final offset = (safePage - 1) * safeLimit;

    final countRows = await conn.execute(
      '''
      SELECT COUNT(*)
      FROM sellers s
      WHERE (
        \$1 = ''
        OR s.shop_name ILIKE '%' || \$1 || '%'
        OR COALESCE(s.description, '') ILIKE '%' || \$1 || '%'
        OR COALESCE(s.inn, '') ILIKE '%' || \$1 || '%'
        OR COALESCE(s.unp, '') ILIKE '%' || \$1 || '%'
      )
      ''',
      parameters: [q],
    );

    final total = _toInt(countRows.first[0]);

    final rows = await conn.execute(
      '''
      SELECT
        s.seller_id,
        s.shop_name,
        s.description,
        s.inn,
        s.unp,
        s.user_id
      FROM sellers s
      WHERE (
        \$1 = ''
        OR s.shop_name ILIKE '%' || \$1 || '%'
        OR COALESCE(s.description, '') ILIKE '%' || \$1 || '%'
        OR COALESCE(s.inn, '') ILIKE '%' || \$1 || '%'
        OR COALESCE(s.unp, '') ILIKE '%' || \$1 || '%'
      )
      ORDER BY s.seller_id DESC
      LIMIT \$2 OFFSET \$3
      ''',
      parameters: [q, safeLimit, offset],
    );

    return Response.json(
      body: {
        'page': safePage,
        'limit': safeLimit,
        'total': total,
        'items': rows
            .map(
              (row) => {
                'seller_id': row[0],
                'shop_name': row[1],
                'description': row[2],
                'inn': row[3],
                'unp': row[4],
                'user_id': row[5],
              },
            )
            .toList(),
      },
    );
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final shopName = _toStringValue(data['shop_name']);
    final description = _toStringValue(data['description']);
    final inn = _toStringValue(data['inn']);
    final unp = _toStringValue(data['unp']);
    final userId = _toInt(data['user_id']);

    if (shopName.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'shop_name is required'},
      );
    }

    if (userId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'user_id is required'},
      );
    }

    final userRows = await conn.execute(
      '''
      SELECT user_id
      FROM users
      WHERE user_id = \$1
      LIMIT 1
      ''',
      parameters: [userId],
    );

    if (userRows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'User not found'},
      );
    }

    final existingSeller = await conn.execute(
      '''
      SELECT seller_id
      FROM sellers
      WHERE user_id = \$1
      LIMIT 1
      ''',
      parameters: [userId],
    );

    if (existingSeller.length > 0) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'Seller for this user already exists'},
      );
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO sellers (
        shop_name,
        description,
        inn,
        unp,
        user_id
      )
      VALUES (\$1, \$2, \$3, \$4, \$5)
      RETURNING
        seller_id,
        shop_name,
        description,
        inn,
        unp,
        user_id
      ''',
      parameters: [
        shopName,
        description.isEmpty ? null : description,
        inn.isEmpty ? null : inn,
        unp.isEmpty ? null : unp,
        userId,
      ],
    );

    final row = inserted.first;

    return Response.json(
      statusCode: 201,
      body: {
        'seller_id': row[0],
        'shop_name': row[1],
        'description': row[2],
        'inn': row[3],
        'unp': row[4],
        'user_id': row[5],
      },
    );
  }

  return Response(statusCode: 405);
}
