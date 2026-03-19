import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_controller.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersController>().loadOrders();
    });
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();

    if (value.contains('new') || value.contains('нов')) {
      return Colors.blue;
    }
    if (value.contains('paid') || value.contains('оплач')) {
      return Colors.green;
    }
    if (value.contains('cancel') || value.contains('отмен')) {
      return Colors.red;
    }
    if (value.contains('deliver') || value.contains('достав')) {
      return Colors.orange;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Мои заказы')),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error && state.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить заказы',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<OrdersController>().loadOrders(),
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64),
                        SizedBox(height: 12),
                        Text(
                          'Заказов пока нет',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersController>().loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final statusColor = _statusColor(order.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Заказ #${order.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Сумма: ${order.totalAmount}'),
                        Text('Товаров: ${order.itemsCount}'),
                        Text('Дата: ${order.createdAt}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push(
                        '${AppRoutes.buyerOrderDetails}?id=${order.orderId}',
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
