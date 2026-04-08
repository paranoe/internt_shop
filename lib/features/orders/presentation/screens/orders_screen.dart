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

  String _statusText(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created' || value.contains('new')) return 'Создан';
    if (value == 'paid') return 'Оплачен';
    if (value == 'delivered') return 'Доставлен';
    if (value == 'cancelled' || value.contains('cancel')) return 'Отменён';
    if (value.contains('deliver')) return 'Доставляется';

    return status;
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created' || value.contains('new')) {
      return Colors.blue;
    }
    if (value == 'paid') {
      return Colors.green;
    }
    if (value == 'delivered') {
      return Colors.teal;
    }
    if (value == 'cancelled' || value.contains('cancel')) {
      return Colors.red;
    }
    if (value.contains('deliver')) {
      return Colors.orange;
    }

    return Colors.grey;
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;

    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year}';
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
                            _statusText(order.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (order.previewItems.isNotEmpty) ...[
                          SizedBox(
                            height: 46,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: order.previewItems.length > 3
                                  ? 3
                                  : order.previewItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, imageIndex) {
                                final item = order.previewItems[imageIndex];

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    color: const Color(0xFFF1F3F9),
                                    child:
                                        item.imageUrl == null ||
                                            item.imageUrl!.isEmpty
                                        ? const Icon(
                                            Icons.image_outlined,
                                            size: 20,
                                          )
                                        : Image.network(
                                            item.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 20,
                                                ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text('Сумма: ${order.totalAmount}'),
                        Text('Товаров: ${order.itemsCount}'),
                        Text('Дата: ${_formatDate(order.createdAt)}'),
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
