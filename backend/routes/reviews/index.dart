import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final productId = int.tryParse(data['product_id']?.toString() ?? '');
  final rating = int.tryParse(data['rating']?.toString() ?? '');
  final commentRaw = data['comment']?.toString().trim();
  final comment =
      (commentRaw == null || commentRaw.isEmpty) ? null : commentRaw;

  if (productId == null || rating == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'product_id and rating required'},
    );
  }

  if (rating < 1 || rating > 5) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'rating must be between 1 and 5'},
    );
  }

  final productRows = await conn.execute(
    '''
    SELECT product_id
    FROM products
    WHERE product_id = \$1
    LIMIT 1
    ''',
    parameters: [productId],
  );

  if (productRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }

  // Разрешаем отзыв только если buyer реально покупал этот товар
  final purchaseRows = await conn.execute(
    '''
    SELECT 1
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
    WHERE o.buyer_id = \$1
      AND o.status = 'delivered'
      AND ci.product_id = \$2
    LIMIT 1
    ''',
    parameters: [auth.userId, productId],
  );

  if (purchaseRows.isEmpty) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'You can review only delivered purchased products'},
    );
  }

  final existingRows = await conn.execute(
    '''
    SELECT review_id
    FROM reviews
    WHERE buyer_id = \$1 AND product_id = \$2
    LIMIT 1
    ''',
    parameters: [auth.userId, productId],
  );

  if (existingRows.isNotEmpty) {
    final reviewId = (existingRows.first[0] as num).toInt();

    await conn.execute(
      '''
      UPDATE reviews
      SET rating = \$1,
          comment = \$2
      WHERE review_id = \$3
      ''',
      parameters: [rating, comment, reviewId],
    );

    return Response.json(
      body: {
        'review_id': reviewId,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
        'updated': true,
      },
    );
  }

  final inserted = await conn.execute(
    '''
    INSERT INTO reviews (buyer_id, product_id, rating, comment, created_at)
    VALUES (\$1, \$2, \$3, \$4, now())
    RETURNING review_id
    ''',
    parameters: [auth.userId, productId, rating, comment],
  );

  return Response.json(
    statusCode: 201,
    body: {
      'review_id': inserted.first[0],
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'updated': false,
    },
  );
}
