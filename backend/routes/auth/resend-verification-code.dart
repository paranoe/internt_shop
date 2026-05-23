import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/email_code_generator.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/integrations/email/email_service.dart';
import 'package:backend/src/integrations/redis/email_code_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final email = data['email']?.toString().trim().toLowerCase() ?? '';
  if (email.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'email required'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT COALESCE(email_verified, false)
    FROM users
    WHERE email = \$1
    LIMIT 1
    ''',
    parameters: [email],
  );

  if (rows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'User not found'},
    );
  }

  final verified = rows.first[0] == true;
  if (verified) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Email already verified'},
    );
  }

  final code = EmailCodeGenerator.generate();
  final codeStore = EmailCodeStore();
  await codeStore.saveVerifyCode(email: email, code: code);

  final emailService = EmailService();
  await emailService.sendVerificationCode(email: email, code: code);

  return Response.json(
    body: {'sent': true},
  );
}
