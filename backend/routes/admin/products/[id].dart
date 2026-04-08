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
  final productId = int.tryParse(id);
  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT
        p.product_id,
        p.category_id,
        p.seller_id,
        p.name,
        p.description,
        p.price,
        p.quantity,
        p.created_at,
        p.currency,
        p.subcategory_id
      FROM products p
      WHERE p.product_id = \$1
      LIMIT 1
      ''',
      parameters: [productId],
    );

    if (rows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Product not found'},
      );
    }

    final row = rows.first;

    final imageRows = await conn.execute(
      '''
      SELECT
        image_id,
        product_id,
        image_url,
        sort_order
      FROM product_images
      WHERE product_id = \$1
      ORDER BY sort_order ASC, image_id ASC
      ''',
      parameters: [productId],
    );

    return Response.json(
      body: {
        'product': {
          'product_id': row[0],
          'category_id': row[1],
          'seller_id': row[2],
          'name': row[3],
          'description': row[4],
          'price': row[5].toString(),
          'quantity': row[6],
          'created_at': row[7]?.toString(),
          'currency': row[8],
          'subcategory_id': row[9],
        },
        'images': imageRows
            .map(
              (img) => {
                'image_id': img[0],
                'product_id': img[1],
                'image_url': img[2],
                'sort_order': img[3],
              },
            )
            .toList(),
      },
    );
  }

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final updates = <String>[];
    final params = <Object?>[];
    var index = 1;

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

    if (data.containsKey('seller_id')) {
      final sellerId = _toInt(data['seller_id']);
      if (sellerId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'seller_id must be valid'},
        );
      }

      final sellerRows = await conn.execute(
        '''
        SELECT seller_id
        FROM sellers
        WHERE seller_id = \$1
        LIMIT 1
        ''',
        parameters: [sellerId],
      );

      if (sellerRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Seller not found'},
        );
      }

      updates.add('seller_id = \$$index');
      params.add(sellerId);
      index++;
    }

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

      if (subcategoryRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Subcategory not found'},
        );
      }

      updates.add('subcategory_id = \$$index');
      params.add(subcategoryId);
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
      params.add(name);
      index++;
    }

    if (data.containsKey('description')) {
      final description = _toStringValue(data['description']);
      updates.add('description = \$$index');
      params.add(description.isEmpty ? null : description);
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
      params.add(priceRaw);
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
      params.add(quantity);
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
      params.add(currency);
      index++;
    }

    if (updates.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'No fields to update'},
      );
    }

    params.add(productId);
    final productIdPos = index;

    final updated = await conn.execute(
      '''
      UPDATE products
      SET ${updates.join(', ')}
      WHERE product_id = \$$productIdPos
      RETURNING
        product_id,
        category_id,
        seller_id,
        name,
        description,
        price,
        quantity,
        created_at,
        currency,
        subcategory_id
      ''',
      parameters: params,
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Product not found'},
      );
    }

    final row = updated.first;

    return Response.json(
      body: {
        'product_id': row[0],
        'category_id': row[1],
        'seller_id': row[2],
        'name': row[3],
        'description': row[4],
        'price': row[5].toString(),
        'quantity': row[6],
        'created_at': row[7]?.toString(),
        'currency': row[8],
        'subcategory_id': row[9],
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM products
      WHERE product_id = \$1
      RETURNING product_id
      ''',
      parameters: [productId],
    );

    if (deleted.length == 0) {
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
  }

  return Response(statusCode: 405);
}
