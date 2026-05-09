import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final q = (context.request.uri.queryParameters['q'] ?? '').trim();

  if (q.isEmpty) {
    return Response.json(
      body: {
        'subcategory_id': null,
        'items': [],
      },
    );
  }

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final productRows = await conn.execute(
    '''
    SELECT subcategory_id, COUNT(*) as cnt
    FROM products
    WHERE name ILIKE \$1
    GROUP BY subcategory_id
    ORDER BY cnt DESC
    LIMIT 2
    ''',
    parameters: ['%$q%'],
  );

  if (productRows.isEmpty) {
    return Response.json(
      body: {
        'subcategory_id': null,
        'items': [],
      },
    );
  }

  if (productRows.length > 1) {
    final firstCount = productRows.first[1] as int;
    final secondCount = productRows[1][1] as int;
    if (firstCount == secondCount) {
      return Response.json(
        body: {
          'subcategory_id': null,
          'items': [],
        },
      );
    }
  }

  final dominantSubcategoryId = productRows.first[0];
  if (dominantSubcategoryId == null) {
    return Response.json(
      body: {
        'subcategory_id': null,
        'items': [],
      },
    );
  }
  final subcategoryId = dominantSubcategoryId as int;

  final subNameResult = await conn.execute(
    'SELECT name FROM podcategories WHERE podcategories_id = \$1',
    parameters: [subcategoryId],
  );
  final subcategoryName = subNameResult.isNotEmpty
      ? subNameResult.first[0]?.toString()
      : null;

  final parameterRows = await conn.execute(
    '''
    SELECT p.parameter_id, p.name, p.data_type
    FROM category_parameters cp
    JOIN parameters p ON p.parameter_id = cp.parameter_id
    WHERE cp.podcategory_id = \$1
    ORDER BY p.name ASC
    ''',
    parameters: [subcategoryId],
  );

  final items = <Map<String, dynamic>>[];

  for (final row in parameterRows) {
    final parameterId = row[0] as int;
    final name = row[1].toString();
    final dataType = row[2].toString();

    final valueRows = await conn.execute(
      '''
      SELECT DISTINCT ppv.value_text
      FROM product_parameter_values ppv
      JOIN products pr ON pr.product_id = ppv.product_id
      WHERE pr.subcategory_id = \$1
        AND ppv.parameter_id = \$2
        AND ppv.value_text IS NOT NULL
        AND BTRIM(ppv.value_text) <> ''
      ORDER BY ppv.value_text ASC
      ''',
      parameters: [subcategoryId, parameterId],
    );

    final values = valueRows.map((r) => r[0].toString()).toList();

    if (values.isEmpty) continue;

    items.add({
      'parameter_id': parameterId,
      'name': name,
      'data_type': dataType,
      'values': values,
    });
  }

  return Response.json(
    body: {
      'subcategory_id': subcategoryId,
      'subcategory_name': subcategoryName,
      'items': items,
    },
  );
}