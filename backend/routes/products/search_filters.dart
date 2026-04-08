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

  final subRows = await conn.execute(
    '''
    SELECT
      p.subcategory_id,
      COUNT(*) AS cnt
    FROM products p
    WHERE p.name ILIKE \$1
      AND p.subcategory_id IS NOT NULL
    GROUP BY p.subcategory_id
    ORDER BY cnt DESC
    LIMIT 2
    ''',
    parameters: ['%$q%'],
  );

  if (subRows.isEmpty) {
    return Response.json(
      body: {
        'subcategory_id': null,
        'items': [],
      },
    );
  }

  if (subRows.length > 1) {
    final firstCount = (subRows[0][1] as int);
    final secondCount = (subRows[1][1] as int);

    if (firstCount == secondCount) {
      return Response.json(
        body: {
          'subcategory_id': null,
          'items': [],
        },
      );
    }
  }

  final subcategoryId = subRows.first[0] as int;

  final parameterRows = await conn.execute(
    '''
    SELECT
      p.parameter_id,
      p.name,
      p.data_type
    FROM category_parameters cp
    JOIN parameters p
      ON p.parameter_id = cp.parameter_id
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
      JOIN products pr
        ON pr.product_id = ppv.product_id
      WHERE pr.subcategory_id = \$1
        AND pr.name ILIKE \$2
        AND ppv.parameter_id = \$3
        AND ppv.value_text IS NOT NULL
        AND BTRIM(ppv.value_text) <> ''
      ORDER BY ppv.value_text ASC
      ''',
      parameters: [subcategoryId, '%$q%', parameterId],
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
      'items': items,
    },
  );
}
