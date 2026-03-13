class Validators {
  Validators._();

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите email';

    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegExp.hasMatch(text)) {
      return 'Некорректный email';
    }

    return null;
  }

  static String? password(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите пароль';
    if (text.length < 6) return 'Минимум 6 символов';
    return null;
  }
}
