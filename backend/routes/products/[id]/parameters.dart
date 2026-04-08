import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final podcategoryId = int.tryParse(id);
  if (podcategoryId == null || podcategoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid podcategory id'},
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
    WHERE cp.podcategory_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [podcategoryId],
  );

  final items = rows.map((r) {
    return {
      'podcategory_id': r[0],
      'parameter_id': r[1],
      'is_required': r[2],
      'name': r[3],
      'data_type': r[4],
    };
  }).toList();

  return Response.json(body: {'items': items});
}
