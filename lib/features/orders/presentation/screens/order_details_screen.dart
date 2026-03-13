import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_controller.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_state.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersController>().loadOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заказ #${widget.orderId}')),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading &&
              state.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить заказ',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final order = state.selectedOrder;
          if (order == null) {
            return const Center(child: Text('Не удалось загрузить заказ'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заказ #${order.orderId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Статус: ${order.status}'),
                      Text('Сумма: ${order.totalAmount}'),
                      Text('ПВЗ: ${order.pickupPointId}'),
                      Text('Дата: ${order.createdAt}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Товары',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...state.orderItems.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                      'Количество: ${item.quantity}\n'
                      'Цена: ${item.priceSnapshot} ${item.currency}',
                    ),
                    trailing: Text(item.lineTotal),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
