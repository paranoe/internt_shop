import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _maskCard(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return digits;
  final last4 = digits.substring(digits.length - 4);
  return '**** **** **** $last4';
}

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT card_id, card_number
      FROM user_cards
      WHERE user_id = \$1
      ORDER BY card_id DESC
      ''',
      parameters: [auth.userId],
    );

    final items = rows.map((r) {
      return {
        'card_id': r[0],
        'card_number': r[1],
      };
    }).toList();

    return Response.json(body: {'items': items});
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final cardNumberRaw = (data['card_number'] ?? '').toString().trim();
    if (cardNumberRaw.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'card_number required'},
      );
    }

    final masked = _maskCard(cardNumberRaw);

    final inserted = await conn.execute(
      '''
      INSERT INTO user_cards (user_id, card_number)
      VALUES (\$1, \$2)
      RETURNING card_id, card_number
      ''',
      parameters: [auth.userId, masked],
    );

    return Response.json(
      statusCode: 201,
      body: {
        'card_id': inserted.first[0],
        'card_number': inserted.first[1],
      },
    );
  }

  return Response(statusCode: 405);
}
