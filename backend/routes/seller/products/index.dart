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

Future<int?> _resolveSellerId(PostgresClient db, int userId) async {
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT seller_id
    FROM sellers
    WHERE user_id = \$1
    LIMIT 1
    ''',
    parameters: [userId],
  );

  if (rows.isEmpty) return null;
  return _toInt(rows.first[0]);
}

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final sellerId = await _resolveSellerId(db, auth.userId);
  if (sellerId == null) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Seller profile not found'},
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT
          p.product_id,
          p.seller_id,
          s.category_id,
          p.subcategory_id,
          p.name,
          p.description,
          p.price,
          p.currency,
          p.quantity,
          p.created_at
        FROM products p
        JOIN podcategories s
          ON s.podcategories_id = p.subcategory_id
        WHERE p.seller_id = \$1
        ORDER BY p.product_id DESC
        ''',
        parameters: [sellerId],
      );

      return Response.json(
        body: {
          'items': rows.map((row) {
            return {
              'product_id': row[0],
              'seller_id': row[1],
              'category_id': row[2],
              'subcategory_id': row[3],
              'name': row[4],
              'description': row[5],
              'price': row[6].toString(),
              'currency': row[7],
              'quantity': row[8],
              'created_at': row[9]?.toString(),
            };
          }).toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final subcategoryId = _toInt(data['subcategory_id']);
      final name = _toStringValue(data['name']);
      final description = _toStringValue(data['description']);
      final priceRaw = _toStringValue(data['price']);
      final currency = _toStringValue(data['currency'], fallback: 'BYN');
      final quantity = _toInt(data['quantity'], fallback: 0);

      if (subcategoryId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'subcategory_id is required'},
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

      final subcategoryRows = await conn.execute(
        '''
        SELECT podcategories_id, category_id
        FROM podcategories
        WHERE podcategories_id = \$1
        LIMIT 1
        ''',
        parameters: [subcategoryId],
      );

      if (subcategoryRows.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Subcategory not found'},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO products (
          seller_id,
          subcategory_id,
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
          subcategory_id,
          name,
          description,
          price,
          currency,
          quantity,
          created_at
        ''',
        parameters: [
          sellerId,
          subcategoryId,
          name,
          description.isEmpty ? null : description,
          normalizedPrice,
          currency,
          quantity,
        ],
      );

      final row = inserted.first;
      final categoryId = subcategoryRows.first[1];

      return Response.json(
        statusCode: 201,
        body: {
          'product_id': row[0],
          'seller_id': row[1],
          'category_id': categoryId,
          'subcategory_id': row[2],
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
