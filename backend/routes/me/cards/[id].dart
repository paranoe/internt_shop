import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final cardId = int.tryParse(id);
  if (cardId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid card id'});
  }

  final existing = await conn.execute(
    '''
    SELECT card_id
    FROM user_cards
    WHERE card_id = \$1 AND user_id = \$2
    LIMIT 1
    ''',
    parameters: [cardId, auth.userId],
  );

  if (existing.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Card not found'});
  }

  await conn.execute(
    'DELETE FROM user_cards WHERE card_id = \$1',
    parameters: [cardId],
  );

  return Response.json(body: {'ok': true});
}
