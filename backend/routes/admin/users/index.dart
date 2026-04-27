import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/db/postgres_pool.dart';

int _toInt(String? value, int fallback) {
  return int.tryParse(value ?? '') ?? fallback;
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final qp = context.request.uri.queryParameters;

  final page = _toInt(qp['page'], 1).clamp(1, 1000000);
  final limit = _toInt(qp['limit'], 20).clamp(1, 100);
  final q = (qp['q'] ?? '').trim();
  final role = (qp['role'] ?? '').trim();
  final blockedRaw = (qp['blocked'] ?? '').trim().toLowerCase();

  final offset = (page - 1) * limit;

  final where = <String>[];
  final params = <Object?>[];

  if (q.isNotEmpty) {
    final like = '%$q%';
    where.add(
      '''
      (
        u.email ILIKE \$${params.length + 1}
        OR COALESCE(u.phone, '') ILIKE \$${params.length + 2}
        OR COALESCE(u.first_name, '') ILIKE \$${params.length + 3}
        OR COALESCE(u.last_name, '') ILIKE \$${params.length + 4}
        OR COALESCE(u.patronymic, '') ILIKE \$${params.length + 5}
      )
      ''',
    );
    params.add(like);
    params.add(like);
    params.add(like);
    params.add(like);
    params.add(like);
  }

  if (role.isNotEmpty) {
    where.add('r.name = \$${params.length + 1}');
    params.add(role);
  }

  if (blockedRaw == 'true' || blockedRaw == 'false') {
    where.add('COALESCE(u.is_blocked, false) = \$${params.length + 1}');
    params.add(blockedRaw == 'true');
  }

  final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final countRows = await conn.execute(
    '''
    SELECT COUNT(*)
    FROM users u
    JOIN roles r ON r.role_id = u.role_id
    $whereSql
    ''',
    parameters: params,
  );

  final total = int.tryParse(countRows.first[0].toString()) ?? 0;

  final listParams = [...params, limit, offset];
  final limitPos = listParams.length - 1;
  final offsetPos = listParams.length;

  final rows = await conn.execute(
    '''
    SELECT
      u.user_id,
      u.first_name,
      u.last_name,
      u.patronymic,
      u.phone,
      u.email,
      u.gender,
      u.created_at,
      r.name AS role,
      COALESCE(u.is_blocked, false) AS is_blocked
    FROM users u
    JOIN roles r ON r.role_id = u.role_id
    $whereSql
    ORDER BY u.user_id DESC
    LIMIT \$$limitPos OFFSET \$$offsetPos
    ''',
    parameters: listParams,
  );

  final items = rows.map((row) {
    return {
      'user_id': row[0],
      'first_name': row[1],
      'last_name': row[2],
      'patronymic': row[3],
      'phone': row[4],
      'email': row[5],
      'gender': row[6],
      'created_at': row[7]?.toString(),
      'role': row[8],
      'is_blocked': row[9] == true,
    };
  }).toList();

  return Response.json(
    body: {
      'page': page,
      'limit': limit,
      'total': total,
      'items': items,
    },
  );
}
