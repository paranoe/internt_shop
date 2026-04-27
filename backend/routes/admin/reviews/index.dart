import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(String? value, int fallback) {
  return int.tryParse(value ?? '') ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final qp = context.request.uri.queryParameters;
  final page = _toInt(qp['page'], 1).clamp(1, 1000000);
  final limit = _toInt(qp['limit'], 20).clamp(1, 100);
  final status = (qp['status'] ?? '').trim();

  final offset = (page - 1) * limit;

  final where = <String>[];
  final params = <Object?>[];

  if (status.isNotEmpty) {
    where.add('r.moderation_status = \$${params.length + 1}');
    params.add(status);
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM reviews r
    $whereSql
    ''',
    parameters: params,
  );

  final total = int.tryParse(countRows.first[0].toString()) ?? 0;

  final listParams = [...params, limit, offset];
  final limitPos = listParams.length - 1;
  final offsetPos = listParams.length;

  final rows = await conn.execute(
    '''
    SELECT
      r.review_id,
      r.product_id,
      r.buyer_id,
      r.rating,
      r.comment,
      r.created_at,
      r.moderation_status,
      p.name AS product_name,
      u.first_name,
      u.last_name,
      u.email
    FROM reviews r
    JOIN products p ON p.product_id = r.product_id
    JOIN users u ON u.user_id = r.buyer_id
    $whereSql
    ORDER BY r.created_at DESC, r.review_id DESC
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows.map((r) {
    final firstName = r[8]?.toString() ?? '';
    final lastName = r[9]?.toString() ?? '';

    return {
      'review_id': r[0],
      'product_id': r[1],
      'buyer_id': r[2],
      'rating': r[3],
      'comment': r[4],
      'created_at': r[5]?.toString(),
      'moderation_status': r[6],
      'product_name': r[7],
      'buyer_name': '$firstName $lastName'.trim(),
      'buyer_email': r[10],
    };
  }).toList();

  return Response.json(
    body: {
      'page': page,
      'limit': limit,
      'total': total,
      'items': items,
    },
  );
}
