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
      appBar: AppBar(title: Text('Заказ #${widget.orderId}')),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading &&
              state.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error &&
              state.selectedOrder == null) {
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

          final statusColor = _statusColor(order.status);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    Text('Сумма: ${order.totalAmount}'),
                    Text('ПВЗ: ${order.pickupPointId}'),
                    Text('Дата: ${order.createdAt}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Товары',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...state.orderItems.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Количество: ${item.quantity}\n'
                        'Цена: ${item.priceSnapshot} ${item.currency}',
                      ),
                    ),
                    trailing: Text(
                      item.lineTotal,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
