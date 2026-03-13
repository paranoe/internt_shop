import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ оформлен')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Заказ успешно оформлен',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Номер заказа: $orderId',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.buyerOrders),
                  child: const Text('Перейти к заказам'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
