import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrderDetails(widget.orderId);
    });
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created') return Colors.blue;
    if (value == 'paid') return Colors.green;
    if (value == 'shipped') return Colors.orange;
    if (value == 'delivered') return Colors.teal;
    if (value == 'cancelled') return Colors.red;

    return Colors.grey;
  }

  String _statusRu(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created') return 'Создан';
    if (value == 'paid') return 'Оплачен';
    if (value == 'shipped') return 'Отправлен';
    if (value == 'delivered') return 'Доставлен';
    if (value == 'cancelled') return 'Отменён';

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Заказ #${widget.orderId}'),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading &&
              state.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error &&
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
            return const Center(child: Text('Нет данных заказа'));
          }

          final status = order['status']?.toString() ?? '';
          final statusColor = _statusColor(status);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация о заказе',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        _statusRu(status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Покупатель: ${order['buyer_id']}'),
                    Text('ПВЗ: ${order['pickup_point_id']}'),
                    Text('Сумма: ${order['total_amount']}'),
                    Text('Дата: ${order['created_at']}'),
                    const SizedBox(height: 16),
                    if (status == 'created')
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final ok = await context
                                .read<AdminController>()
                                .confirmOrderPayment(widget.orderId);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Оплата подтверждена'
                                      : 'Не удалось подтвердить оплату',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Подтвердить оплату'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Товары в заказе',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (state.selectedOrderItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text('Состав заказа пуст'),
                )
              else
                ...state.selectedOrderItems.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product_name']?.toString() ?? 'Товар',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('product_id: ${item['product_id']}'),
                        Text('Количество: ${item['quantity']}'),
                        Text(
                          'Цена: ${item['price_snapshot']} ${item['currency'] ?? ''}',
                        ),
                        Text('Сумма: ${item['line_total']}'),
                      ],
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
