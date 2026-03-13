import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/middleware/auth_mw.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final sellerId = auth.userId;

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT seller_id, shop_name, description, inn, url
      FROM sellers
      WHERE seller_id = \$1
      ''',
      parameters: [sellerId],
    );

    if (rows.isEmpty) {
      // seller ещё не создал профиль
      return Response.json(
        body: {
          'seller_id': sellerId,
          'shop_name': null,
          'description': null,
          'inn': null,
          'url': null,
          'exists': false,
        },
      );
    }

    final r = rows.first;
    return Response.json(
      body: {
        'seller_id': r[0],
        'shop_name': r[1],
        'description': r[2],
        'inn': r[3],
        'url': r[4],
        'exists': true,
      },
    );
  }

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final shopName = data['shop_name'] as String?;
    final description = data['description'] as String?;
    final inn = data['inn'] as String?;
    final url = data['url'] as String?;

    // upsert profile
    await conn.execute(
      '''
      INSERT INTO sellers (seller_id, shop_name, description, inn, url)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      ON CONFLICT (seller_id) DO UPDATE
      SET shop_name   = EXCLUDED.shop_name,
          description = EXCLUDED.description,
          inn         = EXCLUDED.inn,
          url         = EXCLUDED.url
      ''',
      parameters: [sellerId, shopName, description, inn, url],
    );

    return Response.json(body: {'ok': true});
  }

  return Response(statusCode: 405);
}





