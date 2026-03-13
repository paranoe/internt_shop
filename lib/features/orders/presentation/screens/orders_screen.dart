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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error) {
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
            return const Center(child: Text('Заказов пока нет'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersController>().loadOrders(),
            child: ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('Заказ #${order.orderId}'),
                    subtitle: Text(
                      'Статус: ${order.status}\n'
                      'Сумма: ${order.totalAmount}\n'
                      'Товаров: ${order.itemsCount}',
                    ),
                    isThreeLine: true,
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
