import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final userId = auth.userId;

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT seller_id, user_id, shop_name, description, inn, unp
      FROM sellers
      WHERE user_id = \$1
      LIMIT 1
      ''',
      parameters: [userId],
    );

    if (rows.isEmpty) {
      return Response.json(
        body: {
          'seller_id': null,
          'user_id': userId,
          'shop_name': null,
          'description': null,
          'inn': null,
          'unp': null,
          'exists': false,
        },
      );
    }

    final r = rows.first;
    return Response.json(
      body: {
        'seller_id': r[0],
        'user_id': r[1],
        'shop_name': r[2],
        'description': r[3],
        'inn': r[4],
        'unp': r[5],
        'exists': true,
      },
    );
  }

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final shopName = data['shop_name']?.toString();
    final description = data['description']?.toString();
    final inn = data['inn']?.toString();
    final unp = data['unp']?.toString();

    final rows = await conn.execute(
      '''
      INSERT INTO sellers (user_id, shop_name, description, inn, unp)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      ON CONFLICT (user_id) DO UPDATE
      SET shop_name   = EXCLUDED.shop_name,
          description = EXCLUDED.description,
          inn         = EXCLUDED.inn,
          unp         = EXCLUDED.unp
      RETURNING seller_id, user_id, shop_name, description, inn, unp
      ''',
      parameters: [userId, shopName, description, inn, unp],
    );

    final r = rows.first;

    return Response.json(
      body: {
        'ok': true,
        'seller_id': r[0],
        'user_id': r[1],
        'shop_name': r[2],
        'description': r[3],
        'inn': r[4],
        'unp': r[5],
        'exists': true,
      },
    );
  }

  return Response(statusCode: 405);
}
