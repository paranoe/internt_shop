import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<int?> _resolveSellerId(
  dynamic conn,
  int userId,
) async {
  final rows = await conn.execute(
    '''
    SELECT seller_id
    FROM sellers
    WHERE user_id = \$1
    LIMIT 1
    ''',
    parameters: [userId],
  );

  if (rows.length == 0) return null;
  return _toInt(rows.first[0]);
}

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final sellerId = await _resolveSellerId(conn, user.userId);
  if (sellerId == null) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Seller profile not found'},
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
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
        FROM products
        WHERE seller_id = \$1
          AND (\$2 = '' OR name ILIKE '%' || \$2 || '%')
        ''',
        parameters: [sellerId, q],
      );

      final total = _toInt(countRows.first[0]);

      final rows = await conn.execute(
        '''
        SELECT
          product_id,
          seller_id,
          category_id,
          name,
          description,
          price,
          currency,
          quantity,
          created_at
        FROM products
        WHERE seller_id = \$1
          AND (\$2 = '' OR name ILIKE '%' || \$2 || '%')
        ORDER BY product_id DESC
        LIMIT \$3 OFFSET \$4
        ''',
        parameters: [sellerId, q, safeLimit, offset],
      );

      return Response.json(
        body: {
          'page': safePage,
          'limit': safeLimit,
          'total': total,
          'items': rows
              .map(
                (row) => {
                  'product_id': row[0],
                  'seller_id': row[1],
                  'category_id': row[2],
                  'name': row[3],
                  'description': row[4],
                  'price': row[5].toString(),
                  'currency': row[6],
                  'quantity': row[7],
                  'created_at': row[8]?.toString(),
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final categoryId = _toInt(data['category_id']);
      final name = _toStringValue(data['name']);
      final description = _toStringValue(data['description']);
      final priceRaw = _toStringValue(data['price']);
      final currency = _toStringValue(data['currency'], fallback: 'BYN');
      final quantity = _toInt(data['quantity'], fallback: 0);

      if (categoryId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'category_id is required'},
        );
      }

      if (name.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'name is required'},
        );
      }

      if (priceRaw.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'price is required'},
        );
      }

      final normalizedPrice = priceRaw.replaceAll(',', '.');
      if (double.tryParse(normalizedPrice) == null) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'price must be numeric'},
        );
      }

      if (quantity < 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'quantity must be >= 0'},
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

      final inserted = await conn.execute(
        '''
        INSERT INTO products (
          seller_id,
          category_id,
          name,
          description,
          price,
          currency,
          quantity
        )
        VALUES (\$1, \$2, \$3, \$4, \$5::numeric, \$6, \$7)
        RETURNING
          product_id,
          seller_id,
          category_id,
          name,
          description,
          price,
          currency,
          quantity,
          created_at
        ''',
        parameters: [
          sellerId,
          categoryId,
          name,
          description.isEmpty ? null : description,
          normalizedPrice,
          currency,
          quantity,
        ],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'product_id': row[0],
          'seller_id': row[1],
          'category_id': row[2],
          'name': row[3],
          'description': row[4],
          'price': row[5].toString(),
          'currency': row[6],
          'quantity': row[7],
          'created_at': row[8]?.toString(),
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
