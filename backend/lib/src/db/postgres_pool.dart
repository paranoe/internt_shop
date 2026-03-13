import 'dart:async';
import 'package:postgres/postgres.dart';

import 'package:backend/src/config/env.dart';

class PostgresClient {
  PostgresClient({required Endpoint endpoint}) : _endpoint = endpoint;

  final Endpoint _endpoint;

  Connection? _conn;
  Completer<Connection>? _connecting;

  static PostgresClient fromEnv(Env env) {
    final endpoint = Endpoint(
      host: env.get('DB_HOST'),
      port: env.getInt('DB_PORT'),
      database: env.get('DB_NAME'),
      username: env.get('DB_USER'),
      password: env.get('DB_PASSWORD'),
    );
    return PostgresClient(endpoint: endpoint);
  }

  Future<Connection> get connection async {
    final existing = _conn;
    if (existing != null) return existing;

    final inProgress = _connecting;
    if (inProgress != null) return inProgress.future;

    final completer = Completer<Connection>();
    _connecting = completer;

    try {
      final conn = await Connection.open(
        _endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 10),
        ),
      );
      _conn = conn;
      completer.complete(conn);
      return conn;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _connecting = null;
    }
  }
}




