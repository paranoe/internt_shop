import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final paymentId = int.tryParse(id);
  if (paymentId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid payment id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT
        p.payment_id,
        p.order_id,
        p.payment_method_id,
        p.card_id,
        p.amount,
        p.created_at,
        pm.name AS payment_method_name
      FROM payments p
      LEFT JOIN payment_methods pm ON pm.payment_method_id = p.payment_method_id
      WHERE p.payment_id = \$1
      LIMIT 1
      ''',
      parameters: [paymentId],
    );

    if (rows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Payment not found'},
      );
    }

    final r = rows.first;

    return Response.json(
      body: {
        'payment_id': r[0],
        'order_id': r[1],
        'payment_method_id': r[2],
        'card_id': r[3],
        'amount': r[4].toString(),
        'created_at': r[5].toString(),
        'payment_method_name': r[6],
      },
    );
  }

  if (context.request.method == HttpMethod.patch) {
    final paymentRows = await conn.execute(
      '''
      SELECT
        p.payment_id,
        p.order_id,
        o.status
      FROM payments p
      JOIN orders o ON o.order_id = p.order_id
      WHERE p.payment_id = \$1
      LIMIT 1
      ''',
      parameters: [paymentId],
    );

    if (paymentRows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Payment not found'},
      );
    }

    final row = paymentRows.first;
    final orderId = (row[1] as num).toInt();
    final currentOrderStatus = row[2].toString();

    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final newStatus = (data['status'] ?? '').toString().trim();

    const allowedAdminStatuses = {'paid', 'cancelled'};

    if (!allowedAdminStatuses.contains(newStatus)) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Admin can only set status to paid or cancelled',
        },
      );
    }

    final validTransition =
        (currentOrderStatus == 'created' && newStatus == 'paid') ||
            (currentOrderStatus == 'created' && newStatus == 'cancelled');

    if (!validTransition) {
      return Response.json(
        statusCode: 400,
        body: {
          'error':
              'Invalid status transition. Allowed: created -> paid, created -> cancelled',
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
        'payment_id': paymentId,
        'order_id': orderId,
        'old_status': currentOrderStatus,
        'new_status': newStatus,
      },
    );
  }

  return Response(statusCode: 405);
}
