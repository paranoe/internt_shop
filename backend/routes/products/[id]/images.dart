import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      image_id,
      image_url,
      sort_order
    FROM product_images
    WHERE product_id = \$1
    ORDER BY sort_order NULLS LAST, image_id ASC
    ''',
    parameters: [productId],
  );

  final items = rows.map((r) {
    return {
      'image_id': r[0],
      'image_url': r[1],
      'sort_order': r[2],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
