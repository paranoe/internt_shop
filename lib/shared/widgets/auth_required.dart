import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRequired extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthRequired({
    super.key,
    this.title = 'Нужен вход',
    this.subtitle = 'Войдите или зарегистрируйтесь для доступа',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Войти'),
            ),

            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Регистрация'),
            ),
          ],
        ),
      ),
    );
  }
}
