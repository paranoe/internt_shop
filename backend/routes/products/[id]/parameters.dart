import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get)
    return Response(statusCode: 405);

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid product id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      p.parameter_id,
      p.name,
      p.data_type,
      v.value_text
    FROM product_parameter_values v
    JOIN parameters p ON p.parameter_id = v.parameter_id
    WHERE v.product_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [productId],
  );

  final items = rows
      .map((r) => {
            'parameter_id': r[0],
            'name': r[1],
            'data_type': r[2],
            'value': r[3],
          })
      .toList();

  return Response.json(body: {'items': items});
}
