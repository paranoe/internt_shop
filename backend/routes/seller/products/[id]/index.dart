import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import '../../../../lib/src/core/middleware/auth_mw.dart';
import '../../../../lib/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final auth = context.read<AuthUser>();
  final sellerId = auth.userId;

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid product id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.patch) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final sets = <String>[];
    final params = <Object?>[];

    void addSet(String col, Object? value) {
      if (value == null) return;
      sets.add('$col = \$${params.length + 1}');
      params.add(value);
    }

    if (data.containsKey('category_id'))
      addSet('category_id', int.tryParse(data['category_id'].toString()));
    if (data.containsKey('name')) addSet('name', data['name']);
    if (data.containsKey('description'))
      addSet('description', data['description']);
    if (data.containsKey('price'))
      addSet('price', num.tryParse(data['price'].toString()));
    if (data.containsKey('quantity'))
      addSet('quantity', int.tryParse(data['quantity'].toString()));
    if (data.containsKey('currency')) addSet('currency', data['currency']);

    // чистим null-ы
    sets.removeWhere((_) => false);

    if (sets.isEmpty) {
      return Response.json(
          statusCode: 400, body: {'error': 'No fields to update'});
    }

    final updateParams = [...params, sellerId, productId];
    final sellerPos = updateParams.length - 1;
    final productPos = updateParams.length;

    final updated = await conn.execute(
      '''
      UPDATE products
      SET ${sets.join(', ')}
      WHERE seller_id = \$$sellerPos AND product_id = \$$productPos
      RETURNING product_id
      ''',
      parameters: updateParams,
    );

    if (updated.isEmpty) {
      return Response.json(
          statusCode: 404, body: {'error': 'Product not found (or not yours)'});
    }

    return Response.json(body: {'ok': true});
  }

  if (context.request.method == HttpMethod.delete) {
    // удаляем зависимые таблицы (картинки, параметры) чтобы не упасть на FK
    await conn.execute(
      'DELETE FROM product_images WHERE product_id = \$1',
      parameters: [productId],
    );
    await conn.execute(
      'DELETE FROM product_parameter_values WHERE product_id = \$1',
      parameters: [productId],
    );

    final deleted = await conn.execute(
      'DELETE FROM products WHERE seller_id = \$1 AND product_id = \$2 RETURNING product_id',
      parameters: [sellerId, productId],
    );

    if (deleted.isEmpty) {
      return Response.json(
          statusCode: 404, body: {'error': 'Product not found (or not yours)'});
    }

    return Response.json(body: {'ok': true});
  }

  return Response(statusCode: 405);
}
