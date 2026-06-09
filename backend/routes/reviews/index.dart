import 'dart:convert';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

const _bannedWords = <String>[
  'хуй',
  'пизда',
  'ебал',
  'ебать',
  'ебан',
  'сука',
  'бляд',
  'блять',
  'нахуй',
  'долбоеб',
  'мудак',
  'пиздец',
  'хуйня',
  'дерьмо',
];

String _normalize(String value) {
  return value.toLowerCase().trim();
}

bool _containsBannedWords(String? comment) {
  if (comment == null || comment.trim().isEmpty) return false;

  final text = _normalize(comment);

  for (final word in _bannedWords) {
    if (text.contains(word)) return true;
  }

  return false;
}

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _canReview(context);
    case HttpMethod.post:
      return _createReview(context);
    default:
      return Response(statusCode: 405);
  }
}

Future<Response> _canReview(RequestContext context) async {
  final productId = int.tryParse(
    context.request.uri.queryParameters['product_id'] ?? '',
  );

  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {
        'can_review': false,
        'reason': 'product_id is required',
      },
    );
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      o.order_id,
      o.status,
      oi.order_item_id,
      oi.source_cart_item_id,
      ci.product_id
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
    WHERE o.buyer_id = \$1
      AND ci.product_id = \$2
      AND (
        LOWER(o.status) = 'delivered'
        OR LOWER(o.status) = 'доставлен'
        OR o.status ILIKE '%deliver%'
        OR o.status ILIKE '%достав%'
      )
    LIMIT 1
    ''',
    parameters: [auth.userId, productId],
  );

  final list = rows.toList();

  if (list.isEmpty) {
    return Response.json(
      body: {
        'can_review': false,
        'debug_auth_user_id': auth.userId,
        'debug_product_id': productId,
        'reason': 'No delivered order found for this product',
      },
    );
  }

  final row = list.first;

  return Response.json(
    body: {
      'can_review': true,
      'debug_auth_user_id': auth.userId,
      'debug_product_id': productId,
      'debug_order_id': row[0],
      'debug_order_status': row[1],
      'debug_order_item_id': row[2],
      'debug_source_cart_item_id': row[3],
      'debug_cart_product_id': row[4],
    },
  );
}

Future<Response> _createReview(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final raw = await context.request.body();
  final data = (raw.trim().isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final productId = int.tryParse(data['product_id']?.toString() ?? '');
  final rating = int.tryParse(data['rating']?.toString() ?? '');
  final commentRaw = data['comment']?.toString().trim();
  final comment = commentRaw == null || commentRaw.isEmpty ? null : commentRaw;

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

  final productList = productRows.toList();

  if (productList.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Product not found'},
    );
  }

  final purchaseRows = await conn.execute(
    '''
    SELECT 1
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
    WHERE o.buyer_id = \$1
      AND ci.product_id = \$2
      AND (
        LOWER(o.status) = 'delivered'
        OR LOWER(o.status) = 'доставлен'
        OR o.status ILIKE '%deliver%'
        OR o.status ILIKE '%достав%'
      )
    LIMIT 1
    ''',
    parameters: [auth.userId, productId],
  );

  final purchaseList = purchaseRows.toList();

  if (purchaseList.isEmpty) {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'Отзыв можно оставить только после доставки товара',
      },
    );
  }

  final moderationStatus =
      _containsBannedWords(comment) ? 'pending' : 'approved';

  final existingRows = await conn.execute(
    '''
    SELECT review_id
    FROM reviews
    WHERE buyer_id = \$1
      AND product_id = \$2
    LIMIT 1
    ''',
    parameters: [auth.userId, productId],
  );

  final existingList = existingRows.toList();

  if (existingList.isNotEmpty) {
    final existingRow = existingList.first;
    final reviewId = (existingRow[0] as num).toInt();

    await conn.execute(
      '''
      UPDATE reviews
      SET rating = \$1,
          comment = \$2,
          moderation_status = \$3
      WHERE review_id = \$4
      ''',
      parameters: [rating, comment, moderationStatus, reviewId],
    );

    return Response.json(
      body: {
        'review_id': reviewId,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
        'moderation_status': moderationStatus,
        'updated': true,
      },
    );
  }

  final inserted = await conn.execute(
    '''
    INSERT INTO reviews (
      buyer_id,
      product_id,
      rating,
      comment,
      created_at,
      moderation_status
    )
    VALUES (\$1, \$2, \$3, \$4, now(), \$5)
    RETURNING review_id
    ''',
    parameters: [auth.userId, productId, rating, comment, moderationStatus],
  );

  final insertedRow = inserted.toList().first;

  return Response.json(
    statusCode: 201,
    body: {
      'review_id': insertedRow[0],
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'moderation_status': moderationStatus,
      'updated': false,
    },
  );
}
