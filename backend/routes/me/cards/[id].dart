import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }

  final cardId = int.tryParse(id);
  if (cardId == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid card id'},
    );
  }

  final user = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final deleted = await conn.execute(
    '''
    DELETE FROM user_cards
    WHERE card_id = \$1 AND user_id = \$2
    RETURNING card_id
    ''',
    parameters: [cardId, user.userId],
  );

  if (deleted.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Card not found'},
    );
  }

  return Response.json(
    body: {
      'deleted': true,
      'card_id': cardId,
    },
  );
}
