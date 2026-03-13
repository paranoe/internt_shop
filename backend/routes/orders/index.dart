import 'dart:convert';
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

  // total
  final totalRows = await conn.execute(
    'SELECT COUNT(*) FROM orders WHERE buyer_id = \$1',
    parameters: [auth.userId],
  );
  final total = (totalRows.first[0] as int?) ?? 0;

  // list + items_count
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
      ) AS items_count
    FROM orders o
    WHERE o.buyer_id = \$1
    ORDER BY o.created_at DESC, o.order_id DESC
    LIMIT \$2 OFFSET \$3
    ''',
    parameters: [auth.userId, safeLimit, offset],
  );

  final items = rows.map((r) {
    return {
      'order_id': r[0],
      'pickup_point_id': r[1],
      'total_amount': r[2],
      'created_at': r[3].toString(),
      'status': r[4],
      'items_count': r[5],
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
