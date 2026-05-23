import 'package:backend/src/config/env.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  EmailService() : _env = Env.load();

  final Env _env;

  Future<void> sendVerificationCode({
    required String email,
    required String code,
  }) async {
    await _send(
      to: email,
      subject: 'Подтверждение регистрации',
      text: 'Ваш код подтверждения: $code',
    );
  }

  Future<void> sendResetPasswordCode({
    required String email,
    required String code,
  }) async {
    await _send(
      to: email,
      subject: 'Восстановление пароля',
      text: 'Ваш код для восстановления пароля: $code',
    );
  }

  Future<void> _send({
    required String to,
    required String subject,
    required String text,
  }) async {
    final host = _env.get('SMTP_HOST');
    final port = _env.getInt('SMTP_PORT');
    final username = _env.get('SMTP_USERNAME');
    final password = _env.get('SMTP_PASSWORD');
    final from = _env.get('SMTP_FROM');

    final smtpServer = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ssl: port == 465,
      allowInsecure: port != 465,
    );

    final message = Message()
      ..from = Address(from, 'Intern Shop')
      ..recipients.add(to)
      ..subject = subject
      ..text = text;

    await send(message, smtpServer);
  }
}
