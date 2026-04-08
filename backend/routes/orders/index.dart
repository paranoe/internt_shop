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

  final qp = context.request.uri.queryParameters;

  final page = int.tryParse(qp['page'] ?? '1') ?? 1;
  final limit = int.tryParse(qp['limit'] ?? '20') ?? 20;

  final safePage = page < 1 ? 1 : page;
  final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
  final offset = (safePage - 1) * safeLimit;

  final totalRows = await conn.execute(
    'SELECT COUNT(*) FROM orders WHERE buyer_id = \$1',
    parameters: [auth.userId],
  );
  final total = (totalRows.first[0] as int?) ?? 0;

  final rows = await conn.execute(
    '''
    SELECT
      o.order_id,
      o.pickup_point_id,
      o.total_amount,
      o.created_at,
      o.status,
      (
        SELECT COUNT(*)
        FROM order_items oi
        WHERE oi.order_id = o.order_id
      ) AS items_count,
      COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'product_id', x.product_id,
              'product_name', x.product_name,
              'image_url', x.image_url
            )
          )
          FROM (
            SELECT DISTINCT
              p.product_id AS product_id,
              p.name AS product_name,
              (
                SELECT pi.image_url
                FROM product_images pi
                WHERE pi.product_id = p.product_id
                ORDER BY pi.sort_order ASC, pi.image_id ASC
                LIMIT 1
              ) AS image_url
            FROM order_items oi2
            LEFT JOIN cart_items ci2
              ON ci2.cart_item_id = oi2.source_cart_item_id
            LEFT JOIN products p
              ON p.product_id = ci2.product_id
            WHERE oi2.order_id = o.order_id
              AND p.product_id IS NOT NULL
            ORDER BY p.product_id
            LIMIT 3
          ) x
        ),
        '[]'::json
      ) AS preview_items
    FROM orders o
    WHERE o.buyer_id = \$1
    ORDER BY o.created_at DESC, o.order_id DESC
    LIMIT \$2 OFFSET \$3
    ''',
    parameters: [auth.userId, safeLimit, offset],
  );

  final items = rows.map((r) {
    final previewItems = (r[6] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return {
      'order_id': r[0],
      'pickup_point_id': r[1],
      'total_amount': r[2],
      'created_at': r[3].toString(),
      'status': r[4],
      'items_count': r[5],
      'preview_items': previewItems,
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
