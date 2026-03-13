import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(String? v, int def) => int.tryParse(v ?? '') ?? def;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get)
    return Response(statusCode: 405);

  final qp = context.request.uri.queryParameters;

  final page = _toInt(qp['page'], 1).clamp(1, 1000000);
  final limit = _toInt(qp['limit'], 20).clamp(1, 100);
  final q = (qp['q'] ?? '').trim();
  final categoryId = int.tryParse((qp['category_id'] ?? '').trim());
  final sellerId = int.tryParse((qp['seller_id'] ?? '').trim());

  final offset = (page - 1) * limit;

  final where = <String>[];
  final params = <Object?>[];

  if (q.isNotEmpty) {
    where.add('p.name ILIKE \$${params.length + 1}');
    params.add('%$q%');
  }
  if (categoryId != null) {
    where.add('p.category_id = \$${params.length + 1}');
    params.add(categoryId);
  }
  if (sellerId != null) {
    where.add('p.seller_id = \$${params.length + 1}');
    params.add(sellerId);
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM products p
    $whereSql
    ''',
    parameters: params,
  );
  final total = countRows.first[0] as int;

  final listParams = [...params, limit, offset];
  final limitPos = listParams.length - 1; // limit is second last
  final offsetPos = listParams.length; // offset is last

  final rows = await conn.execute(
    '''
    SELECT
      p.product_id,
      p.name,
      p.price,
      p.currency,
      p.quantity,
      p.category_id,
      p.seller_id,
      (
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.product_id
        ORDER BY pi.sort_order ASC, pi.image_id ASC
        LIMIT 1
      ) AS main_image
    FROM products p
    $whereSql
    ORDER BY p.product_id DESC
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows
      .map((r) => {
            'product_id': r[0],
            'name': r[1],
            'price': r[2],
            'currency': r[3],
            'quantity': r[4],
            'category_id': r[5],
            'seller_id': r[6],
            'main_image': r[7],
          })
      .toList();

  return Response.json(body: {
    'page': page,
    'limit': limit,
    'total': total,
    'items': items,
  });
}




