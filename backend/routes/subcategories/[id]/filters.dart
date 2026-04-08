import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final subcategoryId = int.tryParse(id);
  if (subcategoryId == null || subcategoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid subcategory id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final parameterRows = await conn.execute(
    '''
    SELECT
      p.parameter_id,
      p.name,
      p.data_type
    FROM category_parameters cp
    JOIN parameters p
      ON p.parameter_id = cp.parameter_id
    WHERE cp.podcategory_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [subcategoryId],
  );

  final items = <Map<String, dynamic>>[];

  for (final row in parameterRows) {
    final parameterId = row[0] as int;
    final name = row[1].toString();
    final dataType = row[2].toString();

    final valueRows = await conn.execute(
      '''
      SELECT DISTINCT ppv.value_text
      FROM product_parameter_values ppv
      JOIN products pr
        ON pr.product_id = ppv.product_id
      WHERE pr.subcategory_id = \$1
        AND ppv.parameter_id = \$2
        AND ppv.value_text IS NOT NULL
        AND BTRIM(ppv.value_text) <> ''
      ORDER BY ppv.value_text ASC
      ''',
      parameters: [subcategoryId, parameterId],
    );

    final values = valueRows.map((v) => v[0].toString()).toList();

    items.add({
      'parameter_id': parameterId,
      'name': name,
      'data_type': dataType,
      'values': values,
    });
  }

  return Response.json(body: {'items': items});
}
