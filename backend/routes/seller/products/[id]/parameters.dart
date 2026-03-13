import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

import '../../../../lib/src/core/middleware/auth_mw.dart';
import '../../../../lib/src/db/postgres_pool.dart';
import 'package:backend/src/core/security/auth_user.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put)
    return Response(statusCode: 405);

  final auth = context.read<AuthUser>();
  final sellerId = auth.userId;

  final productId = int.tryParse(id);
  if (productId == null) {
    return Response.json(
        statusCode: 400, body: {'error': 'Invalid product id'});
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  // ownership check
  final owns = await conn.execute(
    'SELECT 1 FROM products WHERE product_id = \$1 AND seller_id = \$2',
    parameters: [productId, sellerId],
  );
  if (owns.isEmpty) {
    return Response.json(
        statusCode: 404, body: {'error': 'Product not found (or not yours)'});
  }

  final raw = await context.request.body();
  final data = jsonDecode(raw) as Map<String, dynamic>;
  final items = (data['items'] as List?) ?? const [];

  await conn.runTx((tx) async {
    // wipe old
    await tx.execute(
      'DELETE FROM product_parameter_values WHERE product_id = \$1',
      parameters: [productId],
    );

    // insert new
    for (final item in items) {
      final m = item as Map<String, dynamic>;
      final parameterId = int.tryParse(m['parameter_id'].toString());
      final value = m['value']?.toString();

      if (parameterId == null || value == null) continue;

      await tx.execute(
        '''
        INSERT INTO product_parameter_values (product_id, parameter_id, value_text)
        VALUES (\$1, \$2, \$3)
        ''',
        parameters: [productId, parameterId, value],
      );
    }
  });

  return Response.json(body: {'ok': true});
}
