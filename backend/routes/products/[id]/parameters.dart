import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final productId = int.tryParse(id);
  if (productId == null || productId <= 0) {
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
      ppv.product_id,
      ppv.parameter_id,
      p.name,
      p.data_type,
      ppv.unit_id,
      mu.name AS unit_name,
      mu.short_name AS unit_short_name,
      ppv.value_text
    FROM product_parameter_values ppv
    JOIN parameters p
      ON p.parameter_id = ppv.parameter_id
    LEFT JOIN measurement_units mu
      ON mu.unit_id = ppv.unit_id
    WHERE ppv.product_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [productId],
  );

  final items = rows.map((r) {
    return {
      'product_id': r[0],
      'parameter_id': r[1],
      'name': r[2],
      'data_type': r[3],
      'unit_id': r[4],
      'unit_name': r[5],
      'unit_short_name': r[6],
      'value_text': r[7],
      'value_number': null,
      'value_boolean': null,
    };
  }).toList();

  return Response.json(body: {'items': items});
}
