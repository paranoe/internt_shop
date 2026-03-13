import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final orderId = int.tryParse(id);
  if (orderId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid order id'});
  }

  final sellerRows = await conn.execute(
    '''
    SELECT seller_id
    FROM sellers
    WHERE user_id = \$1
    LIMIT 1
    ''',
    parameters: [auth.userId],
  );

  if (sellerRows.isEmpty) {
    return Response.json(
        statusCode: 404, body: {'error': 'Seller profile not found'});
  }

  final sellerId = (sellerRows.first[0] as num).toInt();

  if (context.request.method == HttpMethod.get) {
    final orderRows = await conn.execute(
      '''
      SELECT
        o.order_id,
        o.buyer_id,
        o.pickup_point_id,
        o.total_amount,
        o.created_at,
        o.status
      FROM orders o
      WHERE o.order_id = \$1
        AND EXISTS (
          SELECT 1
          FROM order_items oi
          JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
          JOIN products p ON p.product_id = ci.product_id
          WHERE oi.order_id = o.order_id
            AND p.seller_id = \$2
        )
      LIMIT 1
      ''',
      parameters: [orderId, sellerId],
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
        (oi.quantity * oi.price_snapshot) AS line_total,
        oi.source_cart_item_id,
        ci.product_id,
        p.name,
        p.currency,
        p.seller_id
      FROM order_items oi
      JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
      JOIN products p ON p.product_id = ci.product_id
      WHERE oi.order_id = \$1
        AND p.seller_id = \$2
      ORDER BY oi.order_item_id ASC
      ''',
      parameters: [orderId, sellerId],
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
        'seller_id': r[8],
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

  if (context.request.method == HttpMethod.patch) {
    final existingRows = await conn.execute(
      '''
      SELECT
        o.order_id,
        o.status
      FROM orders o
      WHERE o.order_id = \$1
        AND EXISTS (
          SELECT 1
          FROM order_items oi
          JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
          JOIN products p ON p.product_id = ci.product_id
          WHERE oi.order_id = o.order_id
            AND p.seller_id = \$2
        )
      LIMIT 1
      ''',
      parameters: [orderId, sellerId],
    );

    if (existingRows.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'Order not found'});
    }

    final currentStatus = existingRows.first[1].toString();

    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final newStatus = (data['status'] ?? '').toString().trim();

    const allowedSellerStatuses = {'shipped', 'delivered'};

    if (!allowedSellerStatuses.contains(newStatus)) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Seller can only set status to shipped or delivered'},
      );
    }

    final validTransition =
        (currentStatus == 'paid' && newStatus == 'shipped') ||
            (currentStatus == 'shipped' && newStatus == 'delivered');

    if (!validTransition) {
      return Response.json(
        statusCode: 400,
        body: {
          'error':
              'Invalid status transition. Allowed: paid -> shipped, shipped -> delivered'
        },
      );
    }

    await conn.execute(
      '''
      UPDATE orders
      SET status = \$1
      WHERE order_id = \$2
      ''',
      parameters: [newStatus, orderId],
    );

    return Response.json(
      body: {
        'ok': true,
        'order_id': orderId,
        'old_status': currentStatus,
        'new_status': newStatus,
      },
    );
  }

  return Response(statusCode: 405);
}
