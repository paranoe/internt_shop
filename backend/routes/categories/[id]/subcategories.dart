import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final categoryId = int.tryParse(id);
  if (categoryId == null || categoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid category id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      podcategories_id,
      name,
      category_id
    FROM podcategories
    WHERE category_id = \$1
    ORDER BY name ASC
    ''',
    parameters: [categoryId],
  );

  final items = rows
      .map(
        (r) => {
          'subcategory_id': r[0],
          'name': r[1],
          'category_id': r[2],
        },
      )
      .toList();

  return Response.json(body: {'items': items});
}
