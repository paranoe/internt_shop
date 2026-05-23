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

Future<Response> onRequest(RequestContext context, String id) async {
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

  final productId = int.tryParse(id);
  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
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
        WHERE p.product_id = \$1
          AND p.seller_id = \$2
        LIMIT 1
        ''',
        parameters: [productId, sellerId],
      );

      if (rows.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Product not found'},
        );
      }

      final row = rows.first;

      return Response.json(
        body: {
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
        },
      );

    case HttpMethod.patch:
      final exists = await conn.execute(
        '''
        SELECT 1
        FROM products
        WHERE product_id = \$1
          AND seller_id = \$2
        LIMIT 1
        ''',
        parameters: [productId, sellerId],
      );

      if (exists.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Product not found'},
        );
      }

      final raw = await context.request.body();
      final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
          as Map<String, dynamic>;

      final updates = <String>[];
      final parameters = <dynamic>[];
      var index = 1;

      if (data.containsKey('subcategory_id')) {
        final subcategoryId = _toInt(data['subcategory_id']);

        if (subcategoryId <= 0) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'subcategory_id must be valid'},
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

        if (subcategoryRows.isEmpty) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Subcategory not found'},
          );
        }

        updates.add('subcategory_id = \$$index');
        parameters.add(subcategoryId);
        index++;
      }

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

      if (data.containsKey('description')) {
        final description = _toStringValue(data['description']);
        updates.add('description = \$$index');
        parameters.add(description.isEmpty ? null : description);
        index++;
      }

      if (data.containsKey('price')) {
        final priceRaw = _toStringValue(data['price']);
        final normalizedPrice = priceRaw.replaceAll(',', '.');

        if (priceRaw.isEmpty || double.tryParse(normalizedPrice) == null) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'price must be numeric'},
          );
        }

        updates.add('price = \$$index::numeric');
        parameters.add(normalizedPrice);
        index++;
      }

      if (data.containsKey('currency')) {
        final currency = _toStringValue(data['currency']);
        if (currency.isEmpty) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'currency cannot be empty'},
          );
        }

        updates.add('currency = \$$index');
        parameters.add(currency);
        index++;
      }

      if (data.containsKey('quantity')) {
        final quantity = _toInt(data['quantity'], fallback: -1);
        if (quantity < 0) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'quantity must be >= 0'},
          );
        }

        updates.add('quantity = \$$index');
        parameters.add(quantity);
        index++;
      }

      if (updates.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'No fields to update'},
        );
      }

      parameters.add(productId);
      parameters.add(sellerId);

      final rows = await conn.execute(
        '''
        UPDATE products
        SET ${updates.join(', ')}
        WHERE product_id = \$$index
          AND seller_id = \$${index + 1}
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
        parameters: parameters,
      );

      if (rows.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Product not found'},
        );
      }

      final row = rows.first;

      final categoryRows = await conn.execute(
        '''
        SELECT category_id
        FROM podcategories
        WHERE podcategories_id = \$1
        LIMIT 1
        ''',
        parameters: [row[2]],
      );

      final categoryId = categoryRows.isEmpty ? null : categoryRows.first[0];

      return Response.json(
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

    case HttpMethod.delete:
      final deleted = await conn.execute(
        '''
        DELETE FROM products
        WHERE product_id = \$1
          AND seller_id = \$2
        RETURNING product_id
        ''',
        parameters: [productId, sellerId],
      );

      if (deleted.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Product not found'},
        );
      }

      return Response.json(
        body: {
          'deleted': true,
          'product_id': productId,
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
