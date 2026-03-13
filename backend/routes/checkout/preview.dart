import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
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

  if (existing.isNotEmpty) return existing.first[0] as int;

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

  final cartId = await _getOrCreateCartId(db, auth.userId);

  final rows = await conn.execute(
    '''
    SELECT
      ci.cart_item_id,
      ci.product_id,
      p.name,
      p.price,
      p.currency,
      ci.quantity
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

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'No items selected for purchase'},
    );
  }

  // проверим валюту (дефолтно считаем, что она одна)
  String? currency;
  num total = 0;

  final items = <Map<String, dynamic>>[];

  for (final r in rows) {
    final cartItemId = r[0] as int;
    final productId = r[1] as int;
    final name = r[2] as String;
    final price = _toNum(r[3]);
    final cur = r[4] as String;
    final qty = r[5] as int;

    currency ??= cur;
    if (currency != cur) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Mixed currencies in cart are not supported yet'},
      );
    }

    final lineTotal = price * qty;
    total += lineTotal;

    items.add({
      'cart_item_id': cartItemId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': qty,
      'line_total': lineTotal,
    });
  }

  return Response.json(
    body: {
      'cart_id': cartId,
      'currency': currency,
      'items': items,
      'total_amount': total,
    },
  );
}
