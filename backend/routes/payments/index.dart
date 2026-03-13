import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}

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

  final orderId = int.tryParse(data['order_id']?.toString() ?? '');
  final paymentMethodId =
      int.tryParse(data['payment_method_id']?.toString() ?? '');
  final cardId =
      data['card_id'] == null ? null : int.tryParse(data['card_id'].toString());

  if (orderId == null || paymentMethodId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'order_id and payment_method_id required'},
    );
  }

  final orderRows = await conn.execute(
    '''
    SELECT order_id, buyer_id, total_amount, status
    FROM orders
    WHERE order_id = \$1
    LIMIT 1
    ''',
    parameters: [orderId],
  );

  if (orderRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Order not found'});
  }

  final order = orderRows.first;
  final buyerId = order[1] as int;
  final amount = _toNum(order[2]);
  final orderStatus = order[3].toString();

  if (buyerId != auth.userId) {
    return Response.json(statusCode: 403, body: {'error': 'Forbidden'});
  }

  if (orderStatus == 'paid') {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Order already paid'},
    );
  }

  final methodRows = await conn.execute(
    '''
    SELECT payment_method_id, name
    FROM payment_methods
    WHERE payment_method_id = \$1
    LIMIT 1
    ''',
    parameters: [paymentMethodId],
  );

  if (methodRows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Payment method not found'},
    );
  }

  final methodName = methodRows.first[1].toString().toLowerCase();

  int? finalCardId;

  if (methodName == 'card') {
    if (cardId == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'card_id required for card payment'},
      );
    }

    final cardRows = await conn.execute(
      '''
      SELECT card_id
      FROM user_cards
      WHERE card_id = \$1 AND user_id = \$2
      LIMIT 1
      ''',
      parameters: [cardId, auth.userId],
    );

    if (cardRows.isEmpty) {
      return Response.json(statusCode: 404, body: {'error': 'Card not found'});
    }

    finalCardId = cardId;
  } else {
    finalCardId = null;
  }

  await conn.execute('BEGIN');
  try {
    final paymentInsert = await conn.execute(
      '''
      INSERT INTO payments (order_id, payment_method_id, card_id, amount, created_at)
      VALUES (\$1, \$2, \$3, \$4, now())
      RETURNING payment_id
      ''',
      parameters: [orderId, paymentMethodId, finalCardId, amount],
    );

    if (methodName == 'card') {
      await conn.execute(
        '''
        UPDATE orders
        SET status = 'paid'
        WHERE order_id = \$1
        ''',
        parameters: [orderId],
      );
    }

    await conn.execute('COMMIT');

    return Response.json(
      statusCode: 201,
      body: {
        'payment_id': paymentInsert.first[0],
        'order_id': orderId,
        'payment_method_id': paymentMethodId,
        'card_id': finalCardId,
        'amount': amount,
        'order_status': methodName == 'card' ? 'paid' : orderStatus,
      },
    );
  } catch (_) {
    await conn.execute('ROLLBACK');
    rethrow;
  }
}
