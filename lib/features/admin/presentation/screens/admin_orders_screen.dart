import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrders();
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

  Future<void> _openOrder(int orderId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminOrderDetailsScreen(orderId: orderId),
      ),
    );

    if (!mounted) return;
    await context.read<AdminController>().loadOrders(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Заказы'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.orders.isEmpty) {
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

          return RefreshIndicator(
            onRefresh: () => context.read<AdminController>().loadOrders(
              status: _selectedStatus,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Фильтр по статусу',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все статусы'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'created',
                      child: Text('Создан'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'paid',
                      child: Text('Оплачен'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'shipped',
                      child: Text('Отправлен'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'delivered',
                      child: Text('Доставлен'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'cancelled',
                      child: Text('Отменён'),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedStatus = value;
                    });
                    await context.read<AdminController>().loadOrders(
                      status: value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (state.orders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Заказов пока нет'),
                  )
                else
                  ...state.orders.map((order) {
                    final orderId =
                        int.tryParse(order['order_id'].toString()) ?? 0;
                    final status = order['status']?.toString() ?? '';
                    final statusColor = _statusColor(status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
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
                            'Заказ #$orderId',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 12),
                          Text('Покупатель: ${order['buyer_id']}'),
                          Text('Сумма: ${order['total_amount']}'),
                          Text('Товаров: ${order['items_count']}'),
                          Text('Дата: ${order['created_at']}'),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openOrder(orderId),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('Открыть заказ'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
