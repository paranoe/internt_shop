import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  if (method != HttpMethod.get && method != HttpMethod.patch) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;
  final user = context.read<AuthUser>();

  if (method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.patronymic,
        u.phone,
        u.email,
        u.gender,
        u.created_at,
        r.name AS role
      FROM users u
      JOIN roles r ON r.role_id = u.role_id
      WHERE u.user_id = \$1
      LIMIT 1
      ''',
      parameters: [user.userId],
    );

    if (rows.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'User not found'},
      );
    }

    final row = rows.first;

    return Response.json(
      body: {
        'user_id': row[0],
        'first_name': row[1],
        'last_name': row[2],
        'patronymic': row[3],
        'phone': row[4],
        'email': row[5],
        'gender': row[6],
        'created_at': row[7].toString(),
        'role': row[8],
      },
    );
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  String? normalize(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  final firstName = normalize(data['first_name']);
  final lastName = normalize(data['last_name']);
  final patronymic = normalize(data['patronymic']);
  final phone = normalize(data['phone']);
  final gender = normalize(data['gender']);

  if (gender != null && gender != 'male' && gender != 'female') {
    return Response.json(
      statusCode: 400,
      body: {'error': 'gender must be male or female'},
    );
  }

  final updatedRows = await conn.execute(
    '''
    UPDATE users
    SET
      first_name = \$1,
      last_name = \$2,
      patronymic = \$3,
      phone = \$4,
      gender = \$5
    WHERE user_id = \$6
    RETURNING user_id
    ''',
    parameters: [
      firstName,
      lastName,
      patronymic,
      phone,
      gender,
      user.userId,
    ],
  );

  if (updatedRows.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'User not found'},
    );
  }

  final rows = await conn.execute(
    '''
    SELECT
      u.user_id,
      u.first_name,
      u.last_name,
      u.patronymic,
      u.phone,
      u.email,
      u.gender,
      u.created_at,
      r.name AS role
    FROM users u
    JOIN roles r ON r.role_id = u.role_id
    WHERE u.user_id = \$1
    LIMIT 1
    ''',
    parameters: [user.userId],
  );

  final row = rows.first;

  return Response.json(
    body: {
      'user_id': row[0],
      'first_name': row[1],
      'last_name': row[2],
      'patronymic': row[3],
      'phone': row[4],
      'email': row[5],
      'gender': row[6],
      'created_at': row[7].toString(),
      'role': row[8],
    },
  );
}
