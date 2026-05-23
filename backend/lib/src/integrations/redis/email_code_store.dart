import 'dart:convert';

import 'redis_client.dart';

class EmailCodeStore {
  static const _verifyPrefix = 'verify_email:';
  static const _resetPrefix = 'reset_password:';
  static const _ttlSeconds = 600; // 10 минут

  String _verifyKey(String email) => '$_verifyPrefix$email';
  String _resetKey(String email) => '$_resetPrefix$email';

  Future<void> saveVerifyCode({
    required String email,
    required String code,
  }) async {
    final redis = await AppRedisClient.instance();
    final expiresAt = DateTime.now()
        .add(const Duration(seconds: _ttlSeconds))
        .millisecondsSinceEpoch;

    await redis.set(
      _verifyKey(email),
      jsonEncode({
        'code': code,
        'expires_at': expiresAt,
      }),
    );
  }

  Future<String?> getVerifyCode(String email) async {
    final redis = await AppRedisClient.instance();
    final raw = await redis.get(_verifyKey(email));
    if (raw == null || raw.isEmpty) return null;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final expiresAt = int.tryParse(data['expires_at'].toString()) ?? 0;

    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await redis.delete(_verifyKey(email));
      return null;
    }

    return data['code']?.toString();
  }

  Future<void> deleteVerifyCode(String email) async {
    final redis = await AppRedisClient.instance();
    await redis.delete(_verifyKey(email));
  }

  Future<void> saveResetCode({
    required String email,
    required String code,
  }) async {
    final redis = await AppRedisClient.instance();
    final expiresAt = DateTime.now()
        .add(const Duration(seconds: _ttlSeconds))
        .millisecondsSinceEpoch;

    await redis.set(
      _resetKey(email),
      jsonEncode({
        'code': code,
        'expires_at': expiresAt,
      }),
    );
  }

  Future<String?> getResetCode(String email) async {
    final redis = await AppRedisClient.instance();
    final raw = await redis.get(_resetKey(email));
    if (raw == null || raw.isEmpty) return null;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final expiresAt = int.tryParse(data['expires_at'].toString()) ?? 0;

    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await redis.delete(_resetKey(email));
      return null;
    }

    return data['code']?.toString();
  }

  Future<void> deleteResetCode(String email) async {
    final redis = await AppRedisClient.instance();
    await redis.delete(_resetKey(email));
  }
}
