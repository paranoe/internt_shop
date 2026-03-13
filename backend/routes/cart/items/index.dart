import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/middleware/auth_roles_mw.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

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

  final raw = await context.request.body();
  final data = jsonDecode(raw) as Map<String, dynamic>;

  final productId = int.tryParse(data['product_id']?.toString() ?? '');
  final quantity = int.tryParse(data['quantity']?.toString() ?? '');
  int? listTypeId = data['list_type_id'] == null
      ? null
      : int.tryParse(data['list_type_id'].toString());
  final selected = data['selected_for_purchase'] == null
      ? true
      : (data['selected_for_purchase'] == true);

  if (productId == null || quantity == null || quantity <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'product_id and quantity (>0) required'},
    );
  }

  final cartId = await _getOrCreateCartId(db, auth.userId);
  final conn = await db.connection;
  final productRows = await conn.execute(
    'SELECT 1 FROM products WHERE product_id = \$1 LIMIT 1',
    parameters: [productId],
  );
  if (productRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }
  if (productRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }
  // если list_type_id не передан — берем id типа "cart"
  if (listTypeId == null) {
    final lt = await conn.execute(
      'SELECT list_type_id FROM list_types WHERE list_type_name = \$1 LIMIT 1',
      parameters: ['cart'],
    );

    if (lt.isEmpty) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'list_types missing: cart'},
      );
    }

    listTypeId = lt.first[0] as int;
  }
  // если товар уже есть в этой корзине (в рамках одного list_type) — увеличиваем quantity
  final existing = await conn.execute(
    '''
  SELECT cart_item_id, quantity
  FROM cart_items
  WHERE cart_id = \$1 AND product_id = \$2
    AND (list_type_id = \$3::int OR (list_type_id IS NULL AND \$3::int IS NULL))
  LIMIT 1
  ''',
    parameters: [cartId, productId, listTypeId],
  );

  if (existing.isNotEmpty) {
    final cartItemId = existing.first[0] as int;
    final oldQty = existing.first[1] as int;
    final newQty = oldQty + quantity;

    await conn.execute(
      '''
      UPDATE cart_items
      SET quantity = \$1,
          selected_for_purchase = \$2
      WHERE cart_item_id = \$3
      ''',
      parameters: [newQty, selected, cartItemId],
    );

    return Response.json(
        body: {'cart_item_id': cartItemId, 'quantity': newQty});
  }

  final inserted = await conn.execute(
    '''
    INSERT INTO cart_items (
      cart_id, product_id, quantity, added_at,
      selected_for_purchase, list_type_id, status
    )
    VALUES (\$1, \$2, \$3, now(), \$4, \$5, 'active')
    RETURNING cart_item_id
    ''',
    parameters: [cartId, productId, quantity, selected, listTypeId],
  );

  return Response.json(
      statusCode: 201, body: {'cart_item_id': inserted.first[0]});
}


