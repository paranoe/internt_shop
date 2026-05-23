import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/email_code_generator.dart';
import 'package:backend/src/core/security/password_hasher.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/integrations/email/email_service.dart';
import 'package:backend/src/integrations/redis/email_code_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final email = data['email']?.toString().trim().toLowerCase() ?? '';
  final password = data['password']?.toString() ?? '';

  final rawRole = data['role']?.toString().trim().toLowerCase();
  final role = (rawRole == null || rawRole.isEmpty) ? 'buyer' : rawRole;

  const allowedRoles = {'buyer', 'seller'};

  if (email.isEmpty || password.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'email and password required'},
    );
  }

  if (!allowedRoles.contains(role)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'role must be buyer or seller'},
    );
  }

  if (password.length < 6) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'password must be at least 6 characters'},
    );
  }

  final existing = await conn.execute(
    '''
    SELECT user_id
    FROM users
    WHERE email = \$1
    LIMIT 1
    ''',
    parameters: [email],
  );

  if (existing.isNotEmpty) {
    return Response.json(
      statusCode: 409,
      body: {'error': 'User already exists'},
    );
  }

  final roleRows = await conn.execute(
    '''
    SELECT role_id
    FROM roles
    WHERE name = \$1
    LIMIT 1
    ''',
    parameters: [role],
  );

  if (roleRows.isEmpty) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Role not found in database'},
    );
  }

  final roleId = (roleRows.first[0] as num).toInt();
  final passwordHash = PasswordHasher.hash(password);

  await conn.execute('BEGIN');
  try {
    final inserted = await conn.execute(
      '''
      INSERT INTO users (email, password_hash, role_id, email_verified, created_at)
      VALUES (\$1, \$2, \$3, false, now())
      RETURNING user_id
      ''',
      parameters: [email, passwordHash, roleId],
    );

    final userId = (inserted.first[0] as num).toInt();

    if (role == 'seller') {
      final shopNameRaw = data['shop_name']?.toString().trim();
      final shopName =
          (shopNameRaw == null || shopNameRaw.isEmpty) ? email : shopNameRaw;

      await conn.execute(
        '''
        INSERT INTO sellers (shop_name, description, inn, url, user_id)
        VALUES (\$1, NULL, NULL, NULL, \$2)
        ''',
        parameters: [shopName, userId],
      );
    }

    await conn.execute('COMMIT');

    final code = EmailCodeGenerator.generate();
    final codeStore = EmailCodeStore();
    await codeStore.saveVerifyCode(email: email, code: code);

    final emailService = EmailService();
    await emailService.sendVerificationCode(email: email, code: code);

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Verification code sent',
        'email': email,
        'user_id': userId,
        'role': role,
      },
    );
  } catch (e) {
    await conn.execute('ROLLBACK');
    rethrow;
  }
}
