import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final qp = context.request.uri.queryParameters;
  final page = int.tryParse(qp['page'] ?? '1') ?? 1;
  final limit = int.tryParse(qp['limit'] ?? '20') ?? 20;
  final orderId = int.tryParse(qp['order_id'] ?? '');

  final safePage = page < 1 ? 1 : page;
  final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
  final offset = (safePage - 1) * safeLimit;

  final where = <String>[];
  final params = <Object?>[];

  if (orderId != null) {
    where.add('p.order_id = \$${params.length + 1}');
    params.add(orderId);
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM payments p
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
      p.payment_id,
      p.order_id,
      p.payment_method_id,
      p.card_id,
      p.amount,
      p.created_at,
      pm.name AS payment_method_name
    FROM payments p
    LEFT JOIN payment_methods pm ON pm.payment_method_id = p.payment_method_id
    $whereSql
    ORDER BY p.created_at DESC, p.payment_id DESC
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows.map((r) {
    return {
      'payment_id': r[0],
      'order_id': r[1],
      'payment_method_id': r[2],
      'card_id': r[3],
      'amount': r[4],
      'created_at': r[5].toString(),
      'payment_method_name': r[6],
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
