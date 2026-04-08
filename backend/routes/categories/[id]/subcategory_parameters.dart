import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final categoryId = int.tryParse(id);
  final subcategoryId = int.tryParse(
    context.request.uri.queryParameters['subcategory_id'] ?? '',
  );

  if (categoryId == null || categoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid category id'},
    );
  }

  if (subcategoryId == null || subcategoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid subcategory id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      cp.podcategory_id,
      cp.parameter_id,
      cp.is_required,
      p.name,
      p.data_type
    FROM category_parameters cp
    JOIN parameters p
      ON p.parameter_id = cp.parameter_id
    JOIN podcategories s
      ON s.podcategories_id = cp.podcategory_id
    WHERE s.category_id = \$1
      AND cp.podcategory_id = \$2
    ORDER BY p.name ASC
    ''',
    parameters: [categoryId, subcategoryId],
  );

  final items = rows
      .map(
        (r) => {
          'subcategory_id': r[0],
          'parameter_id': r[1],
          'is_required': r[2],
          'name': r[3],
          'data_type': r[4],
        },
      )
      .toList();

  return Response.json(body: {'items': items});
}
