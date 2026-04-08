import 'dart:convert';
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

Future<int?> _favoritesListTypeId(dynamic conn) async {
  final rows = await conn.execute(
    '''
    SELECT list_type_id
    FROM list_types
    WHERE list_type_name = \$1
    LIMIT 1
    ''',
    parameters: ['favorites'],
  );

  if (rows.length == 0) return null;
  return rows.first[0] as int;
}

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final favoritesTypeId = await _favoritesListTypeId(conn);
  if (favoritesTypeId == null) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'list_types missing: favorites'},
    );
  }

  if (context.request.method == HttpMethod.get) {
    final cartId = await _getOrCreateCartId(db, auth.userId);

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
        AND ci.list_type_id = \$2
        AND ci.status = 'active'
      ORDER BY ci.added_at DESC, ci.cart_item_id DESC
      ''',
      parameters: [cartId, favoritesTypeId],
    );

    final items = rows.map((r) {
      return {
        'cart_item_id': r[0],
        'product_id': r[1],
        'product_name': r[2],
        'price': _toNum(r[3]).toString(),
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

    return Response.json(body: {'items': items});
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final productId = int.tryParse(data['product_id']?.toString() ?? '');
    if (productId == null || productId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'product_id is required'},
      );
    }

    final cartId = await _getOrCreateCartId(db, auth.userId);

    final productRows = await conn.execute(
      '''
      SELECT 1
      FROM products
      WHERE product_id = \$1
      LIMIT 1
      ''',
      parameters: [productId],
    );

    if (productRows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Product not found'},
      );
    }

    final existing = await conn.execute(
      '''
      SELECT cart_item_id
      FROM cart_items
      WHERE cart_id = \$1
        AND product_id = \$2
        AND list_type_id = \$3
        AND status = 'active'
      LIMIT 1
      ''',
      parameters: [cartId, productId, favoritesTypeId],
    );

    if (existing.length > 0) {
      return Response.json(
        body: {
          'ok': true,
          'cart_item_id': existing.first[0],
          'already_exists': true,
        },
      );
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO cart_items (
        cart_id,
        product_id,
        quantity,
        added_at,
        selected_for_purchase,
        list_type_id,
        status
      )
      VALUES (\$1, \$2, 1, now(), false, \$3, 'active')
      RETURNING cart_item_id
      ''',
      parameters: [cartId, productId, favoritesTypeId],
    );

    return Response.json(
      statusCode: 201,
      body: {
        'ok': true,
        'cart_item_id': inserted.first[0],
      },
    );
  }

  return Response(statusCode: 405);
}
