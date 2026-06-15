import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/di/env.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/utils/price_formatter.dart';
import 'package:diplomeprojectmobile/core/widgets/empty_state_view.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/shared/widgets/auth_required.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartController>().loadCart();
    });
  }

  double _itemLineTotal(CartItem item) {
    final price = double.tryParse(item.price.replaceAll(',', '.')) ?? 0;
    return price * item.quantity;
  }

  List<CartItem> _selectedItems(List<CartItem> items) {
    return items.where((item) => item.selectedForPurchase).toList();
  }

  String _selectedTotal(List<CartItem> items) {
    final selected = _selectedItems(items);
    double total = 0;
    String currency = '';

    for (final item in selected) {
      total += _itemLineTotal(item);
      currency = item.currency;
    }

    return PriceFormatter.format(total.toString(), currency: currency);
  }

  int _selectedCount(List<CartItem> items) {
    int count = 0;
    for (final item in _selectedItems(items)) {
      count += item.quantity;
    }
    return count;
  }

  Future<void> _confirmDelete(CartItem item) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text('Удалить товар'),
            content: Text('Удалить «${item.productName}» из корзины?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) return;
    await context.read<CartController>().deleteItem(item.cartItemId);
  }

  @override
  Widget build(BuildContext context) {
    final isAuth =
        context.watch<AuthController>().state.status ==
        AuthStatus.authenticated;

    if (!isAuth) {
      return const AuthRequired(
        title: 'Корзина недоступна',
        subtitle: 'Войдите, чтобы использовать корзину',
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
      ),

      body: BlocBuilder<CartController, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];
          final selectedItems = _selectedItems(items);

          if (state.status == CartStatus.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.error && items.isEmpty) {
            return _CartErrorView(
              message: state.errorMessage ?? 'Не удалось загрузить корзину',
              onRetry: () => context.read<CartController>().loadCart(),
            );
          }

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<CartController>().loadCart(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyStateView(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Корзина пуста',
                    subtitle:
                        'Добавьте товары из каталога, чтобы оформить заказ.',
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<CartController>().loadCart(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 130),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final lineTotal = _itemLineTotal(item);

                      return _CartItemCard(
                        item: item,
                        lineTotal: lineTotal,
                        onSelectedChanged: (value) {
                          context.read<CartController>().toggleSelected(
                            item.cartItemId,
                            value ?? false,
                          );
                        },
                        onDecrease: item.quantity > 1
                            ? () {
                                context.read<CartController>().decreaseQty(
                                  item.cartItemId,
                                  item.quantity,
                                );
                              }
                            : null,
                        onIncrease: () {
                          context.read<CartController>().increaseQty(
                            item.cartItemId,
                            item.quantity,
                          );
                        },
                        onDelete: () => _confirmDelete(item),
                      );
                    },
                  ),
                ),
              ),
              _CartBottomBar(
                selectedCount: _selectedCount(items),
                total: _selectedTotal(items),
                enabled: selectedItems.isNotEmpty,
                onCheckout: () => context.push(AppRoutes.buyerCheckout),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.lineTotal,
    required this.onSelectedChanged,
    required this.onIncrease,
    required this.onDelete,
    this.onDecrease,
  });

  final CartItem item;
  final double lineTotal;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(-5, 26),
            child: Checkbox(
              value: item.selectedForPurchase,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: onSelectedChanged,
            ),
          ),
          _CartItemImage(imageUrl: item.mainImage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  PriceFormatter.format(item.price, currency: item.currency),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Сумма: ${PriceFormatter.format(lineTotal.toString(), currency: item.currency)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _QuantityStepper(
                  quantity: item.quantity,
                  onDecrease: onDecrease,
                  onIncrease: onIncrease,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.selectedCount,
    required this.total,
    required this.enabled,
    required this.onCheckout,
  });

  final int selectedCount;
  final String total;
  final bool enabled;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Выбрано',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$selectedCount шт.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Итого',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  total,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: enabled ? onCheckout : null,
                child: const Text('Перейти к оформлению'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    this.onDecrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _CartItemImage extends StatelessWidget {
  const _CartItemImage({required this.imageUrl});

  final String? imageUrl;

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${Env.baseUrl}$value';
    }
    return '${Env.baseUrl}/$value';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(imageUrl);

    return Container(
      width: 88,
      height: 112,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedUrl == null
          ? const Icon(Icons.image_outlined, color: AppColors.textMuted)
          : Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textMuted,
              ),
            ),
    );
  }
}

class _CartErrorView extends StatelessWidget {
  const _CartErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
