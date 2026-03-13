import 'dart:convert';

import 'redis_client.dart';

class SessionStore {
  static String _key(String sessionId) => 'refresh:$sessionId';

  Future<void> saveRefreshSession({
    required String sessionId,
    required int userId,
    required String role,
  }) async {
    final redis = await AppRedisClient.instance();
    final payload = jsonEncode({
      'user_id': userId,
      'role': role,
    });

    await redis.set(_key(sessionId), payload);
  }

  Future<Map<String, dynamic>?> getRefreshSession(String sessionId) async {
    final redis = await AppRedisClient.instance();
    final raw = await redis.get(_key(sessionId));
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> deleteRefreshSession(String sessionId) async {
    final redis = await AppRedisClient.instance();
    await redis.delete(_key(sessionId));
  }
}
