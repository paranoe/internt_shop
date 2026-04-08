import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final subcategoryId = int.tryParse(id);
  final parameterId = int.tryParse(
    context.request.uri.queryParameters['parameter_id'] ?? '',
  );

  if (subcategoryId == null || subcategoryId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid subcategory id'},
    );
  }

  if (parameterId == null || parameterId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid parameter id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.delete:
      final deleted = await conn.execute(
        '''
        DELETE FROM category_parameters
        WHERE podcategory_id = \$1
          AND parameter_id = \$2
        RETURNING podcategory_id, parameter_id
        ''',
        parameters: [subcategoryId, parameterId],
      );

      if (deleted.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'Binding not found'},
        );
      }

      return Response.json(
        body: {
          'deleted': true,
          'subcategory_id': subcategoryId,
          'parameter_id': parameterId,
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
