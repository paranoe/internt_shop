import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/middleware/auth_roles_mw.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final cartItemId = int.tryParse(id);
  if (cartItemId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid cart item id'});
  }

  // ownership check: item должен принадлежать корзине пользователя
  final owned = await conn.execute(
    '''
    SELECT ci.cart_item_id
    FROM cart_items ci
    JOIN carts c ON c.cart_id = ci.cart_id
    WHERE ci.cart_item_id = \$1 AND c.user_id = \$2
    ''',
    parameters: [cartItemId, auth.userId],
  );

  if (owned.isEmpty) {
    return Response.json(
        statusCode: 404, body: {'error': 'Cart item not found'});
  }

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final sets = <String>[];
    final params = <Object?>[];

    void addSet(String col, Object? value) {
      if (value == null) return;
      sets.add('$col = \$${params.length + 1}');
      params.add(value);
    }

    if (data.containsKey('quantity')) {
      final q = int.tryParse(data['quantity']?.toString() ?? '');
      if (q == null || q <= 0) {
        return Response.json(
            statusCode: 400, body: {'error': 'quantity must be > 0'});
      }
      addSet('quantity', q);
    }

    if (data.containsKey('selected_for_purchase')) {
      final sel = data['selected_for_purchase'] == true;
      addSet('selected_for_purchase', sel);
    }

    if (data.containsKey('list_type_id')) {
      final lt = data['list_type_id'] == null
          ? null
          : int.tryParse(data['list_type_id'].toString());
      addSet('list_type_id', lt);
    }

    if (data.containsKey('status')) {
      addSet('status', data['status']?.toString());
    }

    if (sets.isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': 'No fields to update'});
    }

    final updateParams = [...params, cartItemId];
    final idPos = updateParams.length;

    await conn.execute(
      '''
      UPDATE cart_items
      SET ${sets.join(', ')}
      WHERE cart_item_id = \$$idPos
      ''',
      parameters: updateParams,
    );

    return Response.json(body: {'ok': true});
  }

  if (context.request.method == HttpMethod.delete) {
    await conn.execute(
      'DELETE FROM cart_items WHERE cart_item_id = \$1',
      parameters: [cartItemId],
    );
    return Response.json(body: {'ok': true});
  }

  return Response(statusCode: 405);
}
