import 'dart:math';

class EmailCodeGenerator {
  static String generate() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
