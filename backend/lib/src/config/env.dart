import 'dart:io';

class Env {
  Env._(this._map);
  final Map<String, String> _map;

  static Env load({String path = '.env'}) {
    final map = <String, String>{};

    final file = File(path);
    if (file.existsSync()) {
      for (final raw in file.readAsLinesSync()) {
        final line = raw.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final idx = line.indexOf('=');
        if (idx <= 0) continue;

        final key = line.substring(0, idx).trim();
        var value = line.substring(idx + 1).trim();

        if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
          value = value.substring(1, value.length - 1);
        }

        map[key] = value;
      }
    }

    map.addAll(Platform.environment.map((k, v) => MapEntry(k, v)));
    return Env._(map);
  }

  String get(String key, {String? defaultValue}) {
    final v = _map[key];
    if (v != null && v.isNotEmpty) return v;
    if (defaultValue != null) return defaultValue;
    throw StateError('Missing env var: $key');
  }

  int getInt(String key, {int? defaultValue}) {
    final v = _map[key];
    if (v == null || v.isEmpty) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env var: $key');
    }
    final parsed = int.tryParse(v);
    if (parsed == null) throw StateError('Env $key is not int: $v');
    return parsed;
  }
}




