import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';

String _maskCardNumber(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');

  if (digits.length < 12 || digits.length > 19) {
    throw const FormatException('Card number must contain 12-19 digits');
  }

  final last4 = digits.substring(digits.length - 4);
  return '**** **** **** $last4';
}

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.get:
      final rows = await conn.execute(
        '''
        SELECT card_id, card_number
        FROM user_cards
        WHERE user_id = \$1
        ORDER BY card_id DESC
        ''',
        parameters: [user.userId],
      );

      return Response.json(
        body: {
          'items': rows
              .map(
                (row) => {
                  'card_id': row[0],
                  'card_number': row[1],
                },
              )
              .toList(),
        },
      );

    case HttpMethod.post:
      final raw = await context.request.body();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final cardNumber = data['card_number'] as String?;
      if (cardNumber == null || cardNumber.trim().isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'card_number is required'},
        );
      }

      late final String masked;
      try {
        masked = _maskCardNumber(cardNumber);
      } catch (e) {
        return Response.json(
          statusCode: 400,
          body: {'error': e.toString()},
        );
      }

      final inserted = await conn.execute(
        '''
        INSERT INTO user_cards (user_id, card_number)
        VALUES (\$1, \$2)
        RETURNING card_id, card_number
        ''',
        parameters: [user.userId, masked],
      );

      final row = inserted.first;

      return Response.json(
        statusCode: 201,
        body: {
          'card_id': row[0],
          'card_number': row[1],
        },
      );

    default:
      return Response(statusCode: 405);
  }
}
