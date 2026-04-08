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

Future<Response> onRequest(RequestContext context, String id) async {
  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

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
    case HttpMethod.patch:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final updates = <String>[];
      final parameters = <dynamic>[];
      var index = 1;

      int? newCategoryId;
      int? newSubcategoryId;

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
        final priceRaw = _toStringValue(data['price']).replaceAll(',', '.');
        if (priceRaw.isEmpty || double.tryParse(priceRaw) == null) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'price must be numeric'},
          );
        }

        updates.add('price = \$$index::numeric');
        parameters.add(priceRaw);
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

      if (data.containsKey('category_id')) {
        final categoryId = _toInt(data['category_id']);
        if (categoryId <= 0) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'category_id must be valid'},
          );
        }
        newCategoryId = categoryId;
      }

      if (data.containsKey('subcategory_id')) {
        final subcategoryId = _toInt(data['subcategory_id']);
        if (subcategoryId <= 0) {
          return Response.json(
            statusCode: 400,
            body: {'error': 'subcategory_id must be valid'},
          );
        }
        newSubcategoryId = subcategoryId;
      }

      if (newCategoryId != null) {
        final categoryRows = await conn.execute(
          '''
          SELECT category_id
          FROM categories
          WHERE category_id = \$1
          LIMIT 1
          ''',
          parameters: [newCategoryId],
        );

        if (categoryRows.isEmpty) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Category not found'},
          );
        }

        updates.add('category_id = \$$index');
        parameters.add(newCategoryId);
        index++;
      }

      if (newSubcategoryId != null) {
        int categoryForCheck = newCategoryId ?? 0;

        if (categoryForCheck <= 0) {
          final currentRows = await conn.execute(
            '''
            SELECT category_id
            FROM products
            WHERE product_id = \$1
              AND seller_id = \$2
            LIMIT 1
            ''',
            parameters: [productId, sellerId],
          );

          if (currentRows.isEmpty) {
            return Response.json(
              statusCode: 404,
              body: {'error': 'Product not found'},
            );
          }

          categoryForCheck = _toInt(currentRows.first[0]);
        }

        final subcategoryRows = await conn.execute(
          '''
          SELECT podcategories_id
          FROM podcategories
          WHERE podcategories_id = \$1
            AND category_id = \$2
          LIMIT 1
          ''',
          parameters: [newSubcategoryId, categoryForCheck],
        );

        if (subcategoryRows.isEmpty) {
          return Response.json(
            statusCode: 404,
            body: {'error': 'Subcategory not found'},
          );
        }

        updates.add('subcategory_id = \$$index');
        parameters.add(newSubcategoryId);
        index++;
      }

      if (updates.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'No fields to update'},
        );
      }

      parameters.add(productId);
      final productIdParam = index;
      index++;

      parameters.add(sellerId);
      final sellerIdParam = index;

      final updated = await conn.execute(
        '''
        UPDATE products
        SET ${updates.join(', ')}
        WHERE product_id = \$$productIdParam
          AND seller_id = \$$sellerIdParam
        RETURNING
          product_id,
          seller_id,
          category_id,
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

      if (updated.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Product not found'},
        );
      }

      final row = updated.first;

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
