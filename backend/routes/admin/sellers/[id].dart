import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

String _toStringValue(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Future<Response> onRequest(RequestContext context, String id) async {
  final sellerId = int.tryParse(id);
  if (sellerId == null || sellerId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid seller id'},
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final rows = await conn.execute(
      '''
      SELECT
        seller_id,
        shop_name,
        description,
        inn,
        unp,
        user_id
      FROM sellers
      WHERE seller_id = \$1
      LIMIT 1
      ''',
      parameters: [sellerId],
    );

    if (rows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Seller not found'},
      );
    }

    final row = rows.first;

    return Response.json(
      body: {
        'seller_id': row[0],
        'shop_name': row[1],
        'description': row[2],
        'inn': row[3],
        'unp': row[4],
        'user_id': row[5],
      },
    );
  }

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final updates = <String>[];
    final params = <Object?>[];
    var index = 1;

    if (data.containsKey('shop_name')) {
      final shopName = _toStringValue(data['shop_name']);
      if (shopName.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'shop_name cannot be empty'},
        );
      }

      updates.add('shop_name = \$$index');
      params.add(shopName);
      index++;
    }

    if (data.containsKey('description')) {
      final description = _toStringValue(data['description']);
      updates.add('description = \$$index');
      params.add(description.isEmpty ? null : description);
      index++;
    }

    if (data.containsKey('inn')) {
      final inn = _toStringValue(data['inn']);
      updates.add('inn = \$$index');
      params.add(inn.isEmpty ? null : inn);
      index++;
    }

    if (data.containsKey('unp')) {
      final unp = _toStringValue(data['unp']);
      updates.add('unp = \$$index');
      params.add(unp.isEmpty ? null : unp);
      index++;
    }

    if (data.containsKey('user_id')) {
      final userId = _toInt(data['user_id']);
      if (userId <= 0) {
        return Response.json(
          statusCode: 400,
          body: {'error': 'user_id must be valid'},
        );
      }

      final userRows = await conn.execute(
        '''
        SELECT user_id
        FROM users
        WHERE user_id = \$1
        LIMIT 1
        ''',
        parameters: [userId],
      );

      if (userRows.length == 0) {
        return Response.json(
          statusCode: 404,
          body: {'error': 'User not found'},
        );
      }

      final existingSeller = await conn.execute(
        '''
        SELECT seller_id
        FROM sellers
        WHERE user_id = \$1
          AND seller_id <> \$2
        LIMIT 1
        ''',
        parameters: [userId, sellerId],
      );

      if (existingSeller.length > 0) {
        return Response.json(
          statusCode: 409,
          body: {'error': 'Seller for this user already exists'},
        );
      }

      updates.add('user_id = \$$index');
      params.add(userId);
      index++;
    }

    if (updates.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'No fields to update'},
      );
    }

    params.add(sellerId);
    final sellerIdPos = index;

    final updated = await conn.execute(
      '''
      UPDATE sellers
      SET ${updates.join(', ')}
      WHERE seller_id = \$$sellerIdPos
      RETURNING
        seller_id,
        shop_name,
        description,
        inn,
        unp,
        user_id
      ''',
      parameters: params,
    );

    if (updated.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Seller not found'},
      );
    }

    final row = updated.first;

    return Response.json(
      body: {
        'seller_id': row[0],
        'shop_name': row[1],
        'description': row[2],
        'inn': row[3],
        'unp': row[4],
        'user_id': row[5],
      },
    );
  }

  if (context.request.method == HttpMethod.delete) {
    final deleted = await conn.execute(
      '''
      DELETE FROM sellers
      WHERE seller_id = \$1
      RETURNING seller_id
      ''',
      parameters: [sellerId],
    );

    if (deleted.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Seller not found'},
      );
    }

    return Response.json(
      body: {
        'deleted': true,
        'seller_id': sellerId,
      },
    );
  }

  return Response(statusCode: 405);
}
