import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final qp = context.request.uri.queryParameters;
  final page = _toInt(qp['page'], fallback: 1);
  final limit = _toInt(qp['limit'], fallback: 20);
  final status = (qp['status'] ?? 'created').trim();

  final safePage = page < 1 ? 1 : page;
  final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
  final offset = (safePage - 1) * safeLimit;

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM orders
    WHERE status = \$1
    ''',
    parameters: [status],
  );

  final total = _toInt(countRows.first[0]);

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
        WHERE oi.order_id = o.order_id
      ) AS items_count
    FROM orders o
    WHERE o.status = \$1
    ORDER BY o.created_at DESC, o.order_id DESC
    LIMIT \$2 OFFSET \$3
    ''',
    parameters: [status, safeLimit, offset],
  );

  final items = rows.map((r) {
    return {
      'order_id': r[0],
      'buyer_id': r[1],
      'pickup_point_id': r[2],
      'total_amount': r[3].toString(),
      'created_at': r[4].toString(),
      'status': r[5],
      'items_count': r[6],
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
