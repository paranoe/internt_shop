import 'dart:io';

import 'package:redis_dart_client/redis_dart_client.dart';

class AppRedisClient {
  AppRedisClient._(this._client);

  final RedisClient _client;
  static AppRedisClient? _instance;

  static Future<AppRedisClient> instance() async {
    if (_instance != null) return _instance!;

    final host = Platform.environment['REDIS_HOST'] ?? 'localhost';
    final port = int.tryParse(Platform.environment['REDIS_PORT'] ?? '') ?? 6379;

    final client = RedisClient(host: host, port: port);
    await client.connect();

    _instance = AppRedisClient._(client);
    return _instance!;
  }

  Future<void> set(String key, String value) async {
    await _client.set(key, value);
  }

  Future<String?> get(String key) async {
    final result = await _client.get(key);
    return result?.toString();
  }

  Future<void> delete(String key) async {
    await _client.delete([key]);
  }
}
