import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  print('CAN REVIEW ROUTE HIT');

  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

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
