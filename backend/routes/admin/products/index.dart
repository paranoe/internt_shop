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

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final qp = context.request.uri.queryParameters;
    final page = _toInt(qp['page'], fallback: 1);
    final limit = _toInt(qp['limit'], fallback: 20);
    final q = _toStringValue(qp['q']);
    final categoryId = int.tryParse((qp['category_id'] ?? '').trim());
    final subcategoryId = int.tryParse((qp['subcategory_id'] ?? '').trim());
    final sellerId = int.tryParse((qp['seller_id'] ?? '').trim());

    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 20 : (limit > 100 ? 100 : limit);
    final offset = (safePage - 1) * safeLimit;

    final where = <String>[];
    final params = <Object?>[];

    if (q.isNotEmpty) {
      where.add('p.name ILIKE \$${params.length + 1}');
      params.add('%$q%');
    }

    if (categoryId != null && categoryId > 0) {
      where.add('pc.category_id = \$${params.length + 1}');
      params.add(categoryId);
    }

    if (subcategoryId != null && subcategoryId > 0) {
      where.add('p.subcategory_id = \$${params.length + 1}');
      params.add(subcategoryId);
    }

    if (sellerId != null && sellerId > 0) {
      where.add('p.seller_id = \$${params.length + 1}');
      params.add(sellerId);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final countRows = await conn.execute(
      '''
      SELECT COUNT(*)
      FROM products p
      JOIN podcategories pc
        ON pc.podcategories_id = p.subcategory_id
      $whereSql
      ''',
      parameters: params,
    );

    final total = _toInt(countRows.first[0]);

    final listParams = [...params, safeLimit, offset];
    final limitPos = listParams.length - 1;
    final offsetPos = listParams.length;

    final rows = await conn.execute(
      '''
      SELECT
        p.product_id,
        pc.category_id,
        p.seller_id,
        p.name,
        p.description,
        p.price,
        p.quantity,
        p.created_at,
        p.currency,
        p.subcategory_id,
        (
          SELECT pi.image_url
          FROM product_images pi
          WHERE pi.product_id = p.product_id
          ORDER BY pi.sort_order ASC, pi.image_id ASC
          LIMIT 1
        ) AS main_image
      FROM products p
      JOIN podcategories pc
        ON pc.podcategories_id = p.subcategory_id
      $whereSql
      ORDER BY p.product_id DESC
      LIMIT \$$limitPos OFFSET \$$offsetPos
      ''',
      parameters: listParams,
    );

    return Response.json(
      body: {
        'page': safePage,
        'limit': safeLimit,
        'total': total,
        'items': rows
            .map(
              (row) => {
                'product_id': row[0],
                'category_id': row[1],
                'seller_id': row[2],
                'name': row[3],
                'description': row[4],
                'price': row[5].toString(),
                'quantity': row[6],
                'created_at': row[7]?.toString(),
                'currency': row[8],
                'subcategory_id': row[9],
                'main_image': row[10],
              },
            )
            .toList(),
      },
    );
  }

  if (context.request.method == HttpMethod.post) {
    final raw = await context.request.body();
    final data = (raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw))
        as Map<String, dynamic>;

    final categoryId = _toInt(data['category_id']);
    final sellerId = _toInt(data['seller_id']);
    final subcategoryId = _toInt(data['subcategory_id']);
    final name = _toStringValue(data['name']);
    final description = _toStringValue(data['description']);
    final priceRaw = _toStringValue(data['price']).replaceAll(',', '.');
    final quantity = _toInt(data['quantity'], fallback: -1);
    final currency = _toStringValue(data['currency'], fallback: 'BYN');

    if (categoryId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'category_id is required'},
      );
    }

    if (sellerId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'seller_id is required'},
      );
    }

    if (subcategoryId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'subcategory_id is required'},
      );
    }

    if (name.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'name is required'},
      );
    }

    if (priceRaw.isEmpty || double.tryParse(priceRaw) == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'price must be numeric'},
      );
    }

    if (quantity < 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'quantity must be >= 0'},
      );
    }

    final sellerRows = await conn.execute(
      '''
      SELECT seller_id
      FROM sellers
      WHERE seller_id = \$1
      LIMIT 1
      ''',
      parameters: [sellerId],
    );

    if (sellerRows.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Seller not found'},
      );
    }

    final subcategoryRows = await conn.execute(
      '''
      SELECT podcategories_id, category_id
      FROM podcategories
      WHERE podcategories_id = \$1
      LIMIT 1
      ''',
      parameters: [subcategoryId],
    );

    if (subcategoryRows.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Subcategory not found'},
      );
    }

    final realCategoryId = _toInt(subcategoryRows.first[1]);
    if (realCategoryId != categoryId) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'subcategory does not belong to category'},
      );
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO products (
        seller_id,
        name,
        description,
        price,
        quantity,
        currency,
        subcategory_id
      )
      VALUES (\$1, \$2, \$3, \$4::numeric, \$5, \$6, \$7)
      RETURNING
        product_id,
        seller_id,
        name,
        description,
        price,
        quantity,
        created_at,
        currency,
        subcategory_id
      ''',
      parameters: [
        sellerId,
        name,
        description.isEmpty ? null : description,
        priceRaw,
        quantity,
        currency,
        subcategoryId,
      ],
    );

    final row = inserted.first;

    return Response.json(
      statusCode: 201,
      body: {
        'product_id': row[0],
        'category_id': realCategoryId,
        'seller_id': row[1],
        'name': row[2],
        'description': row[3],
        'price': row[4].toString(),
        'quantity': row[5],
        'created_at': row[6]?.toString(),
        'currency': row[7],
        'subcategory_id': row[8],
      },
    );
  }

  return Response(statusCode: 405);
}
