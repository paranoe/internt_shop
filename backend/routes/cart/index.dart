import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

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

  if (existing.length > 0) {
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

num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();

  final cartId = await _getOrCreateCartId(db, auth.userId);
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      ci.cart_item_id,
      ci.product_id,
      p.name,
      p.price,
      p.currency,
      ci.quantity,
      ci.selected_for_purchase,
      ci.list_type_id,
      lt.list_type_name,
      ci.status,
      ci.added_at,
      (
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.product_id
        ORDER BY pi.sort_order ASC, pi.image_id ASC
        LIMIT 1
      ) AS main_image
    FROM cart_items ci
    JOIN products p ON p.product_id = ci.product_id
    LEFT JOIN list_types lt ON lt.list_type_id = ci.list_type_id
    WHERE ci.cart_id = \$1
      AND ci.status = 'active'
    ORDER BY ci.added_at DESC, ci.cart_item_id DESC
    ''',
    parameters: [cartId],
  );

  final items = rows.map((r) {
    return {
      'cart_item_id': r[0],
      'product_id': r[1],
      'product_name': r[2],
      'price': _toNum(r[3]),
      'currency': r[4],
      'quantity': r[5],
      'selected_for_purchase': r[6],
      'list_type_id': r[7],
      'list_type_name': r[8],
      'status': r[9],
      'added_at': r[10].toString(),
      'main_image': r[11],
    };
  }).toList();

  num total = 0;
  for (final it in items) {
    final selected = it['selected_for_purchase'] == true;
    if (!selected) continue;

    final price = (it['price'] as num?) ?? 0;
    final qty = (it['quantity'] as int?) ?? 0;
    total += price * qty;
  }

  final normalizedTotal = double.parse(total.toStringAsFixed(2));

  return Response.json(
    body: {
      'cart_id': cartId,
      'user_id': auth.userId,
      'total_selected_amount': normalizedTotal,
      'items': items,
    },
  );
}
