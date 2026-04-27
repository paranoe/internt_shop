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

  final rows = await conn.execute(
    '''
    SELECT
      p.parameter_id,
      p.name,
      p.data_type,
      p.unit_id,
      mu.name AS unit_name,
      mu.short_name AS unit_short_name
    FROM category_parameters cp
    JOIN parameters p
      ON p.parameter_id = cp.parameter_id
    LEFT JOIN measurement_units mu
      ON mu.unit_id = p.unit_id
    WHERE cp.podcategory_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [subcategoryId],
  );

  final items = rows.map((r) {
    return {
      'parameter_id': r[0],
      'name': r[1],
      'data_type': r[2],
      'unit_id': r[3],
      'unit_name': r[4],
      'unit_short_name': r[5],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
