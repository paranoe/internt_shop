import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
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
    if (value == 'created' || value.contains('new') || value.contains('нов')) {
      return Colors.blue;
    }
    if (value == 'paid' || value.contains('оплач')) return Colors.green;
    if (value == 'cancelled' || value.contains('cancel') || value.contains('отмен')) {
      return Colors.red;
    }
    if (value == 'delivered' || value.contains('достав')) return Colors.teal;
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
      appBar: AppBar(
        title: Text('Заказ #${widget.orderId}'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.selectedOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error && state.selectedOrder == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Не удалось загрузить заказ',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () {
                        context.read<OrdersController>().loadOrderDetails(widget.orderId);
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Информация о заказе',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        _StatusBadge(text: _statusText(order.status), color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Номер заказа', value: '#${order.orderId}'),
                    _InfoRow(label: 'Сумма', value: '${order.totalAmount}'),
                    _InfoRow(label: 'ПВЗ', value: '${order.pickupPointId}'),
                    _InfoRow(
                      label: 'Дата',
                      value: _formatDate(order.createdAt),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Товары',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              if (state.orderItems.isEmpty)
                const _SectionCard(child: Text('Состав заказа пуст'))
              else
                ...state.orderItems.map(
                  (item) => _SectionCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: const Color(0xFFF1F3F9),
                            child: item.imageUrl == null || item.imageUrl!.isEmpty
                                ? const Icon(Icons.inventory_2_outlined)
                                : Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image_outlined),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Количество: ${item.quantity}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Цена: ${item.priceSnapshot} ${item.currency}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.lineTotal,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
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
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
