import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/integrations/redis/email_code_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final email = data['email']?.toString().trim().toLowerCase() ?? '';
  final code = data['code']?.toString().trim() ?? '';

  if (email.isEmpty || code.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'email and code required'},
    );
  }

  final codeStore = EmailCodeStore();
  final storedCode = await codeStore.getVerifyCode(email);

  if (storedCode == null || storedCode != code) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid or expired code'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final updated = await conn.execute(
    '''
    UPDATE users
    SET email_verified = true
    WHERE email = \$1
    RETURNING user_id
    ''',
    parameters: [email],
  );

  if (updated.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'User not found'},
    );
  }

  await codeStore.deleteVerifyCode(email);

  return Response.json(
    body: {
      'verified': true,
      'email': email,
    },
  );
}
