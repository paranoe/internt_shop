import 'package:flutter/material.dart';

class AdminListTypesScreen extends StatelessWidget {
  const AdminListTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Типы списков'), centerTitle: true),
      body: const Center(
        child: Text(
          'Экран типов списков\nв разработке',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
