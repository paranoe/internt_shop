import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final sellerRows = await conn.execute(
    '''
    SELECT seller_id
    FROM sellers
    WHERE user_id = \$1
    LIMIT 1
    ''',
    parameters: [auth.userId],
  );

  if (sellerRows.length == 0) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Seller profile not found'},
    );
  }

  final sellerId = (sellerRows.first[0] as num).toInt();

  final qp = context.request.uri.queryParameters;
  final page = int.tryParse(qp['page'] ?? '1') ?? 1;
  final limit = int.tryParse(qp['limit'] ?? '20') ?? 20;
  final status = qp['status']?.trim();

  final safePage = page < 1 ? 1 : page;
  final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
  final offset = (safePage - 1) * safeLimit;

  final where = <String>[
    '''
    EXISTS (
      SELECT 1
      FROM order_items oi
      JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
      JOIN products p ON p.product_id = ci.product_id
      WHERE oi.order_id = o.order_id
        AND p.seller_id = \$1
    )
    '''
  ];
  final params = <Object?>[sellerId];

  if (status != null && status.isNotEmpty) {
    where.add('o.status = \$${params.length + 1}');
    params.add(status);
  }

  final whereSql = 'WHERE ${where.join(' AND ')}';

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM orders o
    $whereSql
    ''',
    parameters: params,
  );

  final total = (countRows.first[0] as num).toInt();

  final listParams = [...params, safeLimit, offset];
  final limitPos = listParams.length - 1;
  final offsetPos = listParams.length;

  final rows = await conn.execute(
    '''
    SELECT
      o.order_id,
      o.buyer_id,
      o.pickup_point_id,
      o.total_amount,
      o.created_at,
      o.status,
      (
        SELECT COUNT(*)
        FROM order_items oi
        JOIN cart_items ci ON ci.cart_item_id = oi.source_cart_item_id
        JOIN products p ON p.product_id = ci.product_id
        WHERE oi.order_id = o.order_id
          AND p.seller_id = \$1
      ) AS seller_items_count
    FROM orders o
    $whereSql
    ORDER BY o.created_at DESC, o.order_id DESC
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows.map((r) {
    return {
      'order_id': r[0],
      'buyer_id': r[1],
      'pickup_point_id': r[2],
      'total_amount': r[3].toString(),
      'created_at': r[4].toString(),
      'status': r[5],
      'seller_items_count': r[6],
    };
  }).toList();

  return Response.json(
    body: {
      'page': safePage,
      'limit': safeLimit,
      'total': total,
      'items': items,
    },
  );
}
