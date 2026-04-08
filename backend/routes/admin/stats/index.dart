import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final ordersTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM orders',
  );

  final ordersCreatedRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM orders
    WHERE status = 'created'
    ''',
  );

  final productsTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM products',
  );

  final sellersTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM sellers',
  );

  final categoriesTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM categories',
  );

  final subcategoriesTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM podcategories',
  );

  final citiesTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM cities',
  );

  final pickupPointsTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM pickup_points',
  );

  final parametersTotalRows = await conn.execute(
    'SELECT COUNT(*) FROM parameters',
  );

  return Response.json(
    body: {
      'orders_total': _toInt(ordersTotalRows.first[0]),
      'orders_created': _toInt(ordersCreatedRows.first[0]),
      'products_total': _toInt(productsTotalRows.first[0]),
      'sellers_total': _toInt(sellersTotalRows.first[0]),
      'categories_total': _toInt(categoriesTotalRows.first[0]),
      'subcategories_total': _toInt(subcategoriesTotalRows.first[0]),
      'cities_total': _toInt(citiesTotalRows.first[0]),
      'pickup_points_total': _toInt(pickupPointsTotalRows.first[0]),
      'parameters_total': _toInt(parametersTotalRows.first[0]),
    },
  );
}
