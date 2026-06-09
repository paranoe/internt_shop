import 'dart:math';

import 'package:backend/src/core/security/auth_user.dart';
import 'package:backend/src/db/postgres_pool.dart';
import 'package:backend/src/integrations/s3_storage.dart';
import 'package:dart_frog/dart_frog.dart';

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

Future<int?> _resolveSellerId(PostgresClient db, int userId) async {
  final conn = await db.connection;

  final rows = await conn.execute(
    '''
    SELECT seller_id
    FROM sellers
    WHERE user_id = \$1
    LIMIT 1
    ''',
    parameters: [userId],
  );

  if (rows.isEmpty) return null;

  return _toInt(rows.first[0]);
}

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final auth = context.read<AuthUser>();
  final db = context.read<PostgresClient>();
  final conn = await db.connection;

  final sellerId = await _resolveSellerId(db, auth.userId);

  if (sellerId == null) {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'Seller profile not found',
        'auth_user_id': auth.userId,
        'auth_role': auth.role,
      },
    );
  }

  final productId = int.tryParse(id);

  if (productId == null || productId <= 0) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid product id'},
    );
  }

  final productRows = await conn.execute(
    '''
    SELECT product_id
    FROM products
    WHERE product_id = \$1
      AND seller_id = \$2
    LIMIT 1
    ''',
    parameters: [productId, sellerId],
  );

  if (productRows.isEmpty) {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'Product does not belong to current seller',
        'product_id': productId,
        'auth_user_id': auth.userId,
        'seller_id': sellerId,
        'auth_role': auth.role,
      },
    );
  }

  final contentType = context.request.headers['content-type'] ?? '';

  if (!_isAllowedImageContentType(contentType)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Only image/jpeg, image/png and image/webp are allowed',
        'content_type': contentType,
      },
    );
  }

  final bytes = await context.request.bytes().fold<List<int>>(
    <int>[],
    (previous, chunk) => previous..addAll(chunk),
  );

  if (bytes.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Empty image'},
    );
  }

  const maxSize = 8 * 1024 * 1024;

  if (bytes.length > maxSize) {
    return Response.json(
      statusCode: 413,
      body: {'error': 'Image is too large. Max size is 8 MB'},
    );
  }

  final ext = _extensionByContentType(contentType);
  final random = Random.secure().nextInt(1 << 32);

  final key =
      'products/$productId/${DateTime.now().millisecondsSinceEpoch}_$random.$ext';

  final s3 = S3Storage.fromEnv();

  final imageUrl = await s3.uploadBytes(
    key: key,
    bytes: bytes,
    contentType: contentType,
  );

  final sortRows = await conn.execute(
    '''
    SELECT COALESCE(MAX(sort_order), 0) + 1
    FROM product_images
    WHERE product_id = \$1
    ''',
    parameters: [productId],
  );

  final sortOrder = (sortRows.first[0] as num).toInt();

  final inserted = await conn.execute(
    '''
    INSERT INTO product_images (product_id, image_url, sort_order)
    VALUES (\$1, \$2, \$3)
    RETURNING image_id
    ''',
    parameters: [productId, imageUrl, sortOrder],
  );

  return Response.json(
    statusCode: 201,
    body: {
      'image_id': inserted.first[0],
      'product_id': productId,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    },
  );
}

bool _isAllowedImageContentType(String contentType) {
  final normalized = contentType.toLowerCase().split(';').first.trim();

  return normalized == 'image/jpeg' ||
      normalized == 'image/jpg' ||
      normalized == 'image/png' ||
      normalized == 'image/webp';
}

String _extensionByContentType(String contentType) {
  final normalized = contentType.toLowerCase().split(';').first.trim();

  switch (normalized) {
    case 'image/jpeg':
    case 'image/jpg':
      return 'jpg';
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    default:
      return 'bin';
  }
}
