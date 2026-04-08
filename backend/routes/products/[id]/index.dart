import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }
  bool canReview = false;
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  try {
    final auth = context.read<AuthUser>();

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

    canReview = purchaseRows.isNotEmpty;
  } catch (_) {
    canReview = false;
  }

  final rows = await conn.execute(
    '''
    SELECT
      p.product_id,
      p.name,
      p.description,
      p.price,
      p.currency,
      p.category_id,
      p.seller_id,
      (
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.product_id
        ORDER BY pi.sort_order NULLS LAST, pi.image_id ASC
        LIMIT 1
      ) AS main_image
    FROM products p
    WHERE p.product_id = \$1
    LIMIT 1
    ''',
    parameters: [productId],
  );

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Product not found'},
    );
  }

  final r = rows.first;

  return Response.json(
    body: {
      'product_id': r[0],
      'name': r[1],
      'description': r[2],
      'price': r[3],
      'currency': r[4],
      'category_id': r[5],
      'seller_id': r[6],
      'main_image': r[7],
      'can_review': canReview,
    },
  );
}
