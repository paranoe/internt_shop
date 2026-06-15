import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_controller.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/shared/widgets/auth_required.dart';

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
      final isAuth =
          context.read<AuthController>().state.status ==
          AuthStatus.authenticated;

      if (!isAuth) return;

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
    if (value == 'created' || value.contains('new')) return Colors.blue;
    if (value == 'paid') return Colors.green;
    if (value == 'delivered') return Colors.teal;
    if (value == 'cancelled' || value.contains('cancel')) return Colors.red;
    if (value.contains('deliver')) return Colors.orange;
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
    final isAuth =
        context.watch<AuthController>().state.status ==
        AuthStatus.authenticated;

    if (!isAuth) {
      return const AuthRequired(
        title: 'Заказы недоступны',
        subtitle: 'Нужно войти, чтобы видеть заказы',
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Мои заказы'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<OrdersController, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OrdersStatus.error && state.orders.isEmpty) {
            return _OrdersMessage(
              icon: Icons.error_outline_rounded,
              title: 'Не удалось загрузить заказы',
              subtitle:
                  state.errorMessage ??
                  'Проверьте соединение и попробуйте снова',
              buttonText: 'Повторить',
              onPressed: () => context.read<OrdersController>().loadOrders(),
            );
          }

          if (state.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<OrdersController>().loadOrders(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  _OrdersMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'Заказов пока нет',
                    subtitle: 'Когда вы оформите заказ, он появится здесь.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersController>().loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final statusColor = _statusColor(order.status);

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      context.push(
                        '${AppRoutes.buyerOrderDetails}?id=${order.orderId}',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Заказ #${order.orderId}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              _StatusBadge(
                                text: _statusText(order.status),
                                color: statusColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (order.previewItems.isNotEmpty) ...[
                            SizedBox(
                              height: 52,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: order.previewItems.length > 4
                                    ? 4
                                    : order.previewItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, imageIndex) {
                                  final item = order.previewItems[imageIndex];
                                  return _PreviewImage(imageUrl: item.imageUrl);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: _SmallInfo(
                                  label: 'Сумма',
                                  value: '${order.totalAmount}',
                                ),
                              ),
                              Expanded(
                                child: _SmallInfo(
                                  label: 'Товаров',
                                  value: '${order.itemsCount}',
                                ),
                              ),
                              Expanded(
                                child: _SmallInfo(
                                  label: 'Дата',
                                  value: _formatDate(order.createdAt),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).paddingOnly(bottom: 14);
              },
            ),
          );
        },
      ),
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

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 52,
        color: const Color(0xFFF1F3F9),
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.image_outlined, size: 22)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, size: 22),
              ),
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}

extension _WidgetPadding on Widget {
  Widget paddingOnly({double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }
}
