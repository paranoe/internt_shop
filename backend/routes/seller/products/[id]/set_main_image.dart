import 'dart:convert';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
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
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final productId = int.tryParse(id);

  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final rawBody = await context.request.body();

  if (rawBody.trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Request body is empty'},
    );
  }

  final body = jsonDecode(rawBody) as Map<String, dynamic>;
  final imageId = int.tryParse(body['image_id']?.toString() ?? '');

  if (imageId == null || imageId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid image id'},
    );
  }

  final sellerId = await _resolveSellerId(db, auth.userId);

  if (sellerId == null) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Seller profile not found'},
    );
  }

  final rows = await conn.execute(
    '''
    SELECT pi.image_id
    FROM product_images pi
    JOIN products p ON p.product_id = pi.product_id
    WHERE pi.product_id = \$1
      AND pi.image_id = \$2
      AND p.seller_id = \$3
    LIMIT 1
    ''',
    parameters: [productId, imageId, sellerId],
  );

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 403,
      body: {'error': 'Image does not belong to current seller product'},
    );
  }

  await conn.execute(
    '''
    UPDATE product_images
    SET sort_order = sort_order + 1
    WHERE product_id = \$1
      AND image_id <> \$2
    ''',
    parameters: [productId, imageId],
  );

  await conn.execute(
    '''
    UPDATE product_images
    SET sort_order = 1
    WHERE product_id = \$1
      AND image_id = \$2
    ''',
    parameters: [productId, imageId],
  );

  return Response.json(
    body: {
      'ok': true,
      'product_id': productId,
      'main_image_id': imageId,
    },
  );
}
