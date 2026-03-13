import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import '../../../lib/src/db/postgres_pool.dart';

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: 405);
  }

  final userId = int.tryParse(id);
  if (userId == null) {
    return Response.json(statusCode: 400, body: {'error': 'Invalid user id'});
  }

  final raw = await context.request.body();
  final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
      as Map<String, dynamic>;

  final roleName = (data['role'] as String?)?.trim(); // admin/seller/buyer

  final firstName = data['first_name'] as String?;
  final lastName = data['last_name'] as String?;
  final patronymic = data['patronymic'] as String?;
  final phone = data['phone'] as String?;
  final gender = data['gender'] as String?;

  final sets = <String>[];
  final params = <Object?>[];

  // role -> role_id
  if (roleName != null && roleName.isNotEmpty) {
    // set role_id via subquery
    sets.add(
        'role_id = (SELECT role_id FROM roles WHERE name = \$${params.length + 1})');
    params.add(roleName);
  }

  void addSet(String column, Object? value) {
    if (value == null) return;
    sets.add('$column = \$${params.length + 1}');
    params.add(value);
  }

  addSet('first_name', firstName);
  addSet('last_name', lastName);
  addSet('patronymic', patronymic);
  addSet('phone', phone);
  addSet('gender', gender);

  if (sets.isEmpty) {
    return Response.json(
        statusCode: 400, body: {'error': 'No fields to update'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  // update
  final updateParams = [...params, userId];
  final userIdPos = updateParams.length;

  final updated = await conn.execute(
    '''
    UPDATE users
    SET ${sets.join(', ')}
    WHERE user_id = \$$userIdPos
    RETURNING user_id
    ''',
    parameters: updateParams,
  );

  if (updated.isEmpty) {
    return Response.json(statusCode: 404, body: {'error': 'User not found'});
  }

  // return fresh user (with role name)
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
    ''',
    parameters: [userId],
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
