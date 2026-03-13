import 'package:dart_frog/dart_frog.dart';

import 'package:backend/src/config/env.dart';
import 'package:backend/src/db/postgres_pool.dart';

final _env = Env.load();
final _db = PostgresClient.fromEnv(_env);

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<PostgresClient>((_) => _db));
}





