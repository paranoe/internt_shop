import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(String? v, int def) => int.tryParse(v ?? '') ?? def;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final qp = context.request.uri.queryParameters;

  final page = _toInt(qp['page'], 1).clamp(1, 1000000);
  final limit = _toInt(qp['limit'], 20).clamp(1, 100);
  final q = (qp['q'] ?? '').trim();
  final categoryId = int.tryParse((qp['category_id'] ?? '').trim());
  final subcategoryId = int.tryParse((qp['subcategory_id'] ?? '').trim());
  final sellerId = int.tryParse((qp['seller_id'] ?? '').trim());

  final minPrice = num.tryParse((qp['min_price'] ?? '').replaceAll(',', '.'));
  final maxPrice = num.tryParse((qp['max_price'] ?? '').replaceAll(',', '.'));
  final minRating = num.tryParse((qp['min_rating'] ?? '').replaceAll(',', '.'));
  final sortBy = (qp['sort_by'] ?? '').trim();

  final offset = (page - 1) * limit;

  final where = <String>[];
  final params = <Object?>[];

  if (q.isNotEmpty) {
    where.add('p.name ILIKE \$${params.length + 1}');
    params.add('%$q%');
  }

  if (categoryId != null) {
    where.add('pc.category_id = \$${params.length + 1}');
    params.add(categoryId);
  }

  if (subcategoryId != null) {
    where.add('p.subcategory_id = \$${params.length + 1}');
    params.add(subcategoryId);
  }

  if (sellerId != null) {
    where.add('p.seller_id = \$${params.length + 1}');
    params.add(sellerId);
  }

  if (minPrice != null) {
    where.add('p.price >= \$${params.length + 1}');
    params.add(minPrice);
  }

  if (maxPrice != null) {
    where.add('p.price <= \$${params.length + 1}');
    params.add(maxPrice);
  }

  if (minRating != null) {
    where.add(
      '''
      COALESCE((
        SELECT AVG(r.rating::numeric)
        FROM reviews r
        WHERE r.product_id = p.product_id
      ), 0) >= \$${params.length + 1}
      ''',
    );
    params.add(minRating);
  }

  final parameterFilters = qp.entries
      .where((e) => e.key.startsWith('param_') && e.value.trim().isNotEmpty)
      .toList();

  for (final entry in parameterFilters) {
    final parameterId = int.tryParse(entry.key.replaceFirst('param_', ''));
    final value = entry.value.trim();

    if (parameterId == null || value.isEmpty) continue;

    where.add(
      '''
      EXISTS (
        SELECT 1
        FROM product_parameter_values ppv
        WHERE ppv.product_id = p.product_id
          AND ppv.parameter_id = \$${params.length + 1}
          AND ppv.value_text ILIKE \$${params.length + 2}
      )
      ''',
    );
    params.add(parameterId);
    params.add('%$value%');
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  String orderBySql;
  switch (sortBy) {
    case 'rating_desc':
      orderBySql = '''
      ORDER BY
        COALESCE((
          SELECT AVG(r.rating::numeric)
          FROM reviews r
          WHERE r.product_id = p.product_id
        ), 0) DESC,
        p.product_id DESC
      ''';
      break;
    case 'price_asc':
      orderBySql = 'ORDER BY p.price ASC, p.product_id DESC';
      break;
    case 'price_desc':
      orderBySql = 'ORDER BY p.price DESC, p.product_id DESC';
      break;
    case 'newest':
      orderBySql = 'ORDER BY p.product_id DESC';
      break;
    case 'popular':
    default:
      orderBySql = '''
      ORDER BY
        COALESCE((
          SELECT COUNT(*)
          FROM reviews r
          WHERE r.product_id = p.product_id
        ), 0) DESC,
        p.product_id DESC
      ''';
      break;
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM products p
    JOIN podcategories pc
      ON pc.podcategories_id = p.subcategory_id
    $whereSql
    ''',
    parameters: params,
  );

  final total = countRows.first[0] as int;

  final listParams = [...params, limit, offset];
  final limitPos = listParams.length - 1;
  final offsetPos = listParams.length;

  final rows = await conn.execute(
    '''
    SELECT
      p.product_id,
      p.name,
      p.price,
      p.currency,
      p.quantity,
      pc.category_id,
      p.subcategory_id,
      p.seller_id,
      COALESCE((
        SELECT ROUND(AVG(r.rating::numeric), 1)
        FROM reviews r
        WHERE r.product_id = p.product_id
      ), 0) AS rating,
      (
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.product_id
        ORDER BY pi.sort_order ASC, pi.image_id ASC
        LIMIT 1
      ) AS main_image
    FROM products p
    JOIN podcategories pc
      ON pc.podcategories_id = p.subcategory_id
    $whereSql
    $orderBySql
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows
      .map(
        (r) => {
          'product_id': r[0],
          'name': r[1],
          'price': r[2],
          'currency': r[3],
          'quantity': r[4],
          'category_id': r[5],
          'subcategory_id': r[6],
          'seller_id': r[7],
          'rating': r[8],
          'main_image': r[9],
        },
      )
      .toList();

  return Response.json(
    body: {
      'page': page,
      'limit': limit,
      'total': total,
      'items': items,
    },
  );
}
