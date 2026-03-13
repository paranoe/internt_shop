import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import '../../../lib/src/core/middleware/auth_mw.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

int _toInt(String? v, int def) => int.tryParse(v ?? '') ?? def;

Future<Response> onRequest(RequestContext context) async {
  final auth = context.read<AuthUser>();
  final sellerId = auth.userId;

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final qp = context.request.uri.queryParameters;
    final page = _toInt(qp['page'], 1).clamp(1, 1000000);
    final limit = _toInt(qp['limit'], 20).clamp(1, 100);
    final offset = (page - 1) * limit;

    final countRows = await conn.execute(
      'SELECT COUNT(*) FROM products WHERE seller_id = \$1',
      parameters: [sellerId],
    );
    final total = countRows.first[0] as int;

    final rows = await conn.execute(
      '''
      SELECT product_id, name, price, currency, quantity, category_id, created_at
      FROM products
      WHERE seller_id = \$1
      ORDER BY product_id DESC
      LIMIT \$2 OFFSET \$3
      ''',
      parameters: [sellerId, limit, offset],
    );

    final items = rows
        .map((r) => {
              'product_id': r[0],
              'name': r[1],
              'price': r[2],
              'currency': r[3],
              'quantity': r[4],
              'category_id': r[5],
              'created_at': r[6].toString(),
            })
        .toList();

    return Response.json(
        body: {'page': page, 'limit': limit, 'total': total, 'items': items});
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final categoryId = int.tryParse(data['category_id'].toString());
    final name = data['name'] as String?;
    final description = data['description'] as String?;
    final price = num.tryParse(data['price'].toString());
    final quantity = int.tryParse(data['quantity'].toString());
    final currency = (data['currency'] as String?) ?? 'RUB';

    if (categoryId == null ||
        name == null ||
        name.isEmpty ||
        price == null ||
        quantity == null) {
      return Response.json(
          statusCode: 400,
          body: {'error': 'category_id, name, price, quantity required'});
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO products (category_id, seller_id, name, description, price, quantity, created_at, currency)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, now(), \$7)
      RETURNING product_id
      ''',
      parameters: [
        categoryId,
        sellerId,
        name,
        description,
        price,
        quantity,
        currency
      ],
    );

    final productId = inserted.first[0] as int;
    return Response.json(statusCode: 201, body: {'product_id': productId});
  }

  return Response(statusCode: 405);
}




