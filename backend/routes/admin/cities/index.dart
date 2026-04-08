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
    final limit = _toInt(qp['limit'], fallback: 50);
    final q = _toStringValue(qp['q']);

    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 50 : (limit > 200 ? 200 : limit);
    final offset = (safePage - 1) * safeLimit;

    final countRows = await conn.execute(
      '''
      SELECT COUNT(*)
      FROM cities
      WHERE (\$1 = '' OR city_name ILIKE '%' || \$1 || '%')
      ''',
      parameters: [q],
    );

    final total = _toInt(countRows.first[0]);

    final rows = await conn.execute(
      '''
      SELECT
        city_id,
        city_name
      FROM cities
      WHERE (\$1 = '' OR city_name ILIKE '%' || \$1 || '%')
      ORDER BY city_name ASC, city_id ASC
      LIMIT \$2 OFFSET \$3
      ''',
      parameters: [q, safeLimit, offset],
    );

    return Response.json(
      body: {
        'page': safePage,
        'limit': safeLimit,
        'total': total,
        'items': rows
            .map(
              (row) => {
                'city_id': row[0],
                'city_name': row[1],
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

    final cityName = _toStringValue(data['city_name']);

    if (cityName.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'city_name is required'},
      );
    }

    final exists = await conn.execute(
      '''
      SELECT city_id
      FROM cities
      WHERE LOWER(city_name) = LOWER(\$1)
      LIMIT 1
      ''',
      parameters: [cityName],
    );

    if (exists.length > 0) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'City already exists'},
      );
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO cities (city_name)
      VALUES (\$1)
      RETURNING city_id, city_name
      ''',
      parameters: [cityName],
    );

    final row = inserted.first;

    return Response.json(
      statusCode: 201,
      body: {
        'city_id': row[0],
        'city_name': row[1],
      },
    );
  }

  return Response(statusCode: 405);
}
