import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/password_hasher.dart';
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
  final newPassword = data['new_password']?.toString() ?? '';

  if (email.isEmpty || code.isEmpty || newPassword.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'email, code and new_password required'},
    );
  }

  if (newPassword.length < 6) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'password must be at least 6 characters'},
    );
  }

  final codeStore = EmailCodeStore();
  final storedCode = await codeStore.getResetCode(email);

  if (storedCode == null || storedCode != code) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid or expired code'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final passwordHash = PasswordHasher.hash(newPassword);

  final updated = await conn.execute(
    '''
    UPDATE users
    SET password_hash = \$1
    WHERE email = \$2
    RETURNING user_id
    ''',
    parameters: [passwordHash, email],
  );

  if (updated.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'User not found'},
    );
  }

  await codeStore.deleteResetCode(email);

  return Response.json(
    body: {'reset': true},
  );
}
