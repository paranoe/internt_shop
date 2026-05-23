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
    SELECT user_id
    FROM users
    WHERE email = \$1
    LIMIT 1
    ''',
    parameters: [email],
  );

  if (rows.isNotEmpty) {
    final code = EmailCodeGenerator.generate();
    final codeStore = EmailCodeStore();
    await codeStore.saveResetCode(email: email, code: code);

    final emailService = EmailService();
    await emailService.sendResetPasswordCode(email: email, code: code);
  }

  return Response.json(
    body: {
      'sent': true,
      'message': 'If account exists, reset code was sent',
    },
  );
}
