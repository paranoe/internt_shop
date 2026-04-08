class ErrorMapper {
  ErrorMapper._();

  static String map(Object error) {
    final text = error.toString();

    if (text.contains('SocketException')) {
      return 'Нет соединения с сервером';
    }

    if (text.contains('TimeoutException')) {
      return 'Сервер долго не отвечает';
    }

    if (text.contains('401')) {
      return 'Сессия истекла. Войдите снова';
    }

    if (text.contains('403')) {
      return 'Недостаточно прав для выполнения действия';
    }

    if (text.contains('404')) {
      return 'Данные не найдены';
    }

    if (text.contains('500')) {
      return 'Ошибка сервера. Попробуйте позже';
    }

    return 'Произошла ошибка. Попробуйте ещё раз';
  }
}
