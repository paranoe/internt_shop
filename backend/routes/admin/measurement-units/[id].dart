import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final unitId = int.tryParse(id);
  if (unitId == null || unitId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid unit id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.delete:
      final deleted = await conn.execute(
        '''
        DELETE FROM measurement_units
        WHERE unit_id = \$1
        RETURNING unit_id
        ''',
        parameters: [unitId],
      );

      if (deleted.isEmpty) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Measurement unit not found'},
        );
      }

      return Response.json(
        body: {
          'deleted': true,
          'unit_id': unitId,
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
