import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final orderId = int.tryParse(id);
  if (orderId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid order id'});
  }

  final orderRows = await conn.execute(
    '''
    SELECT
      o.order_id,
      o.buyer_id,
      o.pickup_point_id,
      o.total_amount::double precision,
      o.created_at,
      o.status
    FROM orders o
    WHERE o.order_id = \$1 AND o.buyer_id = \$2
    LIMIT 1
    ''',
    parameters: [orderId, auth.userId],
  );

  if (orderRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Order not found'});
  }

  final o = orderRows.first;

  final itemRows = await conn.execute(
    '''
    SELECT
      oi.order_item_id,
      oi.quantity,
      oi.price_snapshot,
      (oi.quantity * oi.price_snapshot)::double precision AS line_total,
      oi.source_cart_item_id,

      ci.product_id,
      p.name,
      p.currency
    FROM order_items oi
    LEFT JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
    LEFT JOIN products p ON p.product_id = ci.product_id
    WHERE oi.order_id = \$1
    ORDER BY oi.order_item_id ASC
    ''',
    parameters: [orderId],
  );

  final items = itemRows.map((r) {
    return {
      'order_item_id': r[0],
      'quantity': r[1],
      'price_snapshot': r[2],
      'line_total': r[3],
      'source_cart_item_id': r[4],
      'product_id': r[5],
      'product_name': r[6],
      'currency': r[7],
    };
  }).toList();

  return Response.json(
    body: {
      'order': {
        'order_id': o[0],
        'buyer_id': o[1],
        'pickup_point_id': o[2],
        'total_amount': o[3],
        'created_at': o[4].toString(),
        'status': o[5],
      },
      'items': items,
    },
  );
}
