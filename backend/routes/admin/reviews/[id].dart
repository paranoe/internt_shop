import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: 405);
  }

  final reviewId = int.tryParse(id);
  if (reviewId == null || reviewId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid review id'},
    );
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final moderationStatus = data['moderation_status']?.toString().trim();

  const allowedStatuses = {'pending', 'approved', 'rejected'};

  if (moderationStatus == null || !allowedStatuses.contains(moderationStatus)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'moderation_status must be pending, approved or rejected'
      },
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final updated = await conn.execute(
    '''
    UPDATE reviews
    SET moderation_status = \$1
    WHERE review_id = \$2
    RETURNING review_id, moderation_status
    ''',
    parameters: [moderationStatus, reviewId],
  );

  if (updated.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'Review not found'},
    );
  }

  return Response.json(
    body: {
      'review_id': updated.first[0],
      'moderation_status': updated.first[1],
    },
  );
}
