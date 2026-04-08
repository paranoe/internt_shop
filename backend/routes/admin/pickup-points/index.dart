import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  if (context.request.method == HttpMethod.get) {
    final qp = context.request.uri.queryParameters;
    final page = _toInt(qp['page'], fallback: 1);
    final limit = _toInt(qp['limit'], fallback: 50);
    final cityId = int.tryParse((qp['city_id'] ?? '').trim());

    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 50 : (limit > 200 ? 200 : limit);
    final offset = (safePage - 1) * safeLimit;

    final where = <String>[];
    final params = <Object?>[];

    if (cityId != null && cityId > 0) {
      where.add('pp.city_id = \$${params.length + 1}');
      params.add(cityId);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final countRows = await conn.execute(
      '''
      SELECT COUNT(*)
      FROM pickup_points pp
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
        pp.pickup_point_id,
        pp.city_id,
        c.city_name
      FROM pickup_points pp
      JOIN cities c ON c.city_id = pp.city_id
      $whereSql
      ORDER BY pp.pickup_point_id ASC
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
                'pickup_point_id': row[0],
                'city_id': row[1],
                'city_name': row[2],
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

    final cityId = _toInt(data['city_id']);

    if (cityId <= 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'city_id is required'},
      );
    }

    final cityRows = await conn.execute(
      '''
      SELECT city_id, city_name
      FROM cities
      WHERE city_id = \$1
      LIMIT 1
      ''',
      parameters: [cityId],
    );

    if (cityRows.length == 0) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'City not found'},
      );
    }

    final inserted = await conn.execute(
      '''
      INSERT INTO pickup_points (city_id)
      VALUES (\$1)
      RETURNING pickup_point_id, city_id
      ''',
      parameters: [cityId],
    );

    final row = inserted.first;
    final cityName = cityRows.first[1];

    return Response.json(
      statusCode: 201,
      body: {
        'pickup_point_id': row[0],
        'city_id': row[1],
        'city_name': cityName,
      },
    );
  }

  return Response(statusCode: 405);
}
