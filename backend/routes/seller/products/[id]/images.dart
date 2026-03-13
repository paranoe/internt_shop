import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import '../../../../lib/src/core/middleware/auth_mw.dart';
import '../../../../lib/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final auth = context.read<AuthUser>();
  final sellerId = auth.userId;

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid product id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  // ownership check
  final owns = await conn.execute(
    'SELECT 1 FROM products WHERE product_id = \$1 AND seller_id = \$2',
    parameters: [productId, sellerId],
  );
  if (owns.isEmpty) {
    return Response.json(
        statusCode: 404, body: {'error': 'Product not found (or not yours)'});
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final imageUrl = data['image_url'] as String?;
    final sortOrder = int.tryParse((data['sort_order'] ?? 1).toString()) ?? 1;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': 'image_url required'});
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO product_images (product_id, image_url, sort_order)
      VALUES (\$1, \$2, \$3)
      RETURNING image_id
      ''',
      parameters: [productId, imageUrl, sortOrder],
    );

    return Response.json(
        statusCode: 201, body: {'image_id': inserted.first[0]});
  }

  if (context.request.method == HttpMethod.delete) {
    final qp = context.request.uri.queryParameters;
    final imageId = int.tryParse((qp['image_id'] ?? '').trim());
    if (imageId == null) {
      return Response.json(
          statusCode: 400, body: {'error': 'image_id query param required'});
    }

    final deleted = await conn.execute(
      'DELETE FROM product_images WHERE image_id = \$1 AND product_id = \$2 RETURNING image_id',
      parameters: [imageId, productId],
    );

    if (deleted.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'Image not found'});
    }

    return Response.json(body: {'ok': true});
  }

  return Response(statusCode: 405);
}
