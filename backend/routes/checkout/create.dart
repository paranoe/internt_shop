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

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

bool _isCardMethodName(String name) {
  final value = name.trim().toLowerCase();
  return value.contains('card') ||
      value.contains('карт') ||
      value.contains('visa') ||
      value.contains('mastercard');
}

Future<int> _getOrCreateCartId(PostgresClient db, int userId) async {
  final conn = await db.connection;

  final existing = await conn.execute(
    '''
    SELECT cart_id
    FROM carts
    WHERE user_id = \$1
    ORDER BY created_at DESC
    LIMIT 1
    ''',
    parameters: [userId],
  );

  if (existing.isNotEmpty) {
    return existing.first[0] as int;
  }

  final inserted = await conn.execute(
    '''
    INSERT INTO carts (user_id, created_at)
    VALUES (\$1, now())
    RETURNING cart_id
    ''',
    parameters: [userId],
  );

  return inserted.first[0] as int;
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

  final pickupPointId = _toInt(data['pickup_point_id']);
  final paymentMethodId = _toInt(data['payment_method_id']);
  final cardId = _toInt(data['card_id']);

  if (pickupPointId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'pickup_point_id required'},
    );
  }

  if (paymentMethodId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'payment_method_id required'},
    );
  }

  final pp = await conn.execute(
    '''
    SELECT 1
    FROM pickup_points
    WHERE pickup_point_id = \$1
    LIMIT 1
    ''',
    parameters: [pickupPointId],
  );

  if (pp.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Pickup point not found'},
    );
  }

  final paymentMethodRows = await conn.execute(
    '''
    SELECT payment_method_id, name
    FROM payment_methods
    WHERE payment_method_id = \$1
    LIMIT 1
    ''',
    parameters: [paymentMethodId],
  );

  if (paymentMethodRows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Payment method not found'},
    );
  }

  final paymentMethodName = paymentMethodRows.first[1].toString();
  final cardMethod = _isCardMethodName(paymentMethodName);

  if (cardMethod && cardId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'card_id required for card payment'},
    );
  }

  if (cardId != null) {
    final cardRows = await conn.execute(
      '''
      SELECT card_id
      FROM user_cards
      WHERE card_id = \$1
        AND user_id = \$2
      LIMIT 1
      ''',
      parameters: [cardId, auth.userId],
    );

    if (cardRows.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Card not found'},
      );
    }
  }

  final cartId = await _getOrCreateCartId(db, auth.userId);

  final itemsRows = await conn.execute(
    '''
    SELECT
      ci.cart_item_id,
      ci.quantity,
      p.price
    FROM cart_items ci
    JOIN carts c ON c.cart_id = ci.cart_id
    JOIN products p ON p.product_id = ci.product_id
    WHERE c.user_id = \$1
      AND ci.cart_id = \$2
      AND ci.status = 'active'
      AND ci.selected_for_purchase = true
    ORDER BY ci.added_at DESC, ci.cart_item_id DESC
    ''',
    parameters: [auth.userId, cartId],
  );

  if (itemsRows.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'No items selected for purchase'},
    );
  }

  num total = 0;
  for (final r in itemsRows) {
    final qty = r[1] as int;
    final price = _toNum(r[2]);
    total += price * qty;
  }

  await conn.execute('BEGIN');
  try {
    final orderInsert = await conn.execute(
      '''
      INSERT INTO orders (buyer_id, pickup_point_id, total_amount, created_at, status)
      VALUES (\$1, \$2, \$3, now(), 'created')
      RETURNING order_id
      ''',
      parameters: [auth.userId, pickupPointId, total],
    );

    final orderId = orderInsert.first[0] as int;

    for (final r in itemsRows) {
      final cartItemId = r[0] as int;
      final qty = r[1] as int;
      final price = _toNum(r[2]);

      await conn.execute(
        '''
        INSERT INTO order_items (order_id, quantity, source_cart_item_id, price_snapshot)
        VALUES (\$1, \$2, \$3, \$4)
        ''',
        parameters: [orderId, qty, cartItemId, price],
      );
    }

    await conn.execute(
      '''
      INSERT INTO payments (
        order_id,
        payment_method_id,
        card_id,
        amount,
        created_at
      )
      VALUES (\$1, \$2, \$3, \$4, now())
      ''',
      parameters: [
        orderId,
        paymentMethodId,
        cardMethod ? cardId : null,
        total,
      ],
    );

    await conn.execute(
      '''
      UPDATE cart_items
      SET status = 'ordered',
          selected_for_purchase = false
      WHERE cart_id = \$1
        AND status = 'active'
        AND selected_for_purchase = true
      ''',
      parameters: [cartId],
    );

    await conn.execute('COMMIT');

    return Response.json(
      statusCode: 201,
      body: {
        'order_id': orderId,
        'total_amount': total,
      },
    );
  } catch (e) {
    await conn.execute('ROLLBACK');
    rethrow;
  }
}
