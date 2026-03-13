import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final paymentId = int.tryParse(id);
  if (paymentId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid payment id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT
      p.payment_id,
      p.order_id,
      p.payment_method_id,
      p.card_id,
      p.amount,
      p.created_at,
      pm.name AS payment_method_name
    FROM payments p
    LEFT JOIN payment_methods pm ON pm.payment_method_id = p.payment_method_id
    WHERE p.payment_id = \$1
    LIMIT 1
    ''',
    parameters: [paymentId],
  );

  if (rows.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'Payment not found'});
  }

  final r = rows.first;

  return Response.json(
    body: {
      'payment_id': r[0],
      'order_id': r[1],
      'payment_method_id': r[2],
      'card_id': r[3],
      'amount': r[4],
      'created_at': r[5].toString(),
      'payment_method_name': r[6],
    },
  );
}
