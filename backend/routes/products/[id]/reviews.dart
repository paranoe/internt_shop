import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid product id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final productRows = await conn.execute(
    '''
    SELECT product_id
    FROM products
    WHERE product_id = \$1
    LIMIT 1
    ''',
    parameters: [productId],
  );

  if (productRows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Product not found'});
  }

  final avgRows = await conn.execute(
    '''
    SELECT COUNT(*) AS reviews_count, AVG(rating) AS avg_rating
    FROM reviews
    WHERE product_id = \$1
    ''',
    parameters: [productId],
  );

  final reviewsCount = (avgRows.first[0] as num).toInt();
  final avgRating = _toNum(avgRows.first[1]);

  final rows = await conn.execute(
    '''
    SELECT
      r.review_id,
      r.buyer_id,
      r.rating,
      r.comment,
      r.created_at,
      u.first_name,
      u.last_name
    FROM reviews r
    JOIN users u ON u.user_id = r.buyer_id
    WHERE r.product_id = \$1
    ORDER BY r.created_at DESC, r.review_id DESC
    ''',
    parameters: [productId],
  );

  final items = rows.map((r) {
    final firstName = r[5]?.toString();
    final lastName = r[6]?.toString();

    return {
      'review_id': r[0],
      'buyer_id': r[1],
      'rating': r[2],
      'comment': r[3],
      'created_at': r[4].toString(),
      'buyer_name': [firstName, lastName]
          .where((e) => e != null && e.trim().isNotEmpty)
          .join(' ')
          .trim(),
    };
  }).toList();

  return Response.json(
    body: {
      'product_id': productId,
      'reviews_count': reviewsCount,
      'avg_rating': avgRating,
      'items': items,
    },
  );
}
