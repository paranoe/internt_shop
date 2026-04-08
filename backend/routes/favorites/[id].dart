import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

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

Future<Response> onRequest(RequestContext context, String id) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final productId = int.tryParse(id);
  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final favoritesTypeId = await _favoritesListTypeId(conn);
  if (favoritesTypeId == null) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'list_types missing: favorites'},
    );
  }

  if (context.request.method == HttpMethod.delete) {
    await conn.execute(
      '''
      DELETE FROM cart_items ci
      USING carts c
      WHERE ci.cart_id = c.cart_id
        AND c.user_id = \$1
        AND ci.product_id = \$2
        AND ci.list_type_id = \$3
        AND ci.status = 'active'
      ''',
      parameters: [auth.userId, productId, favoritesTypeId],
    );

    return Response.json(body: {'ok': true});
  }

  return Response(statusCode: 405);
}
