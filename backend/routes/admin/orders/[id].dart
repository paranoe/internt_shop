import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final orderId = int.tryParse(id);
  if (orderId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid order id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

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
      LIMIT 1
      ''',
      parameters: [orderId],
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

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final status = (data['status'] ?? '').toString().trim();
    if (status.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'status required'});
    }

    const allowed = {
      'created',
      'paid',
      'shipped',
      'delivered',
      'cancelled',
    };

    if (!allowed.contains(status)) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid status'},
      );
    }

    final existing = await conn.execute(
      'SELECT order_id FROM orders WHERE order_id = \$1 LIMIT 1',
      parameters: [orderId],
    );

    if (existing.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'Order not found'});
    }

    await conn.execute(
      '''
      UPDATE orders
      SET status = \$1
      WHERE order_id = \$2
      ''',
      parameters: [status, orderId],
    );

    return Response.json(
      body: {
        'ok': true,
        'order_id': orderId,
        'status': status,
      },
    );
  }

  return Response(statusCode: 405);
}
