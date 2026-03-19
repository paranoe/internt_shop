import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_state.dart';

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
    final price = double.tryParse(item.price) ?? 0;
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

    return '${total.toStringAsFixed(2)} ${currency.isEmpty ? '' : currency}'
        .trim();
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
            title: const Text('Удалить товар'),
            content: Text('Удалить "${item.productName}" из корзины?'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Корзина'), centerTitle: true),
      body: BlocBuilder<CartController, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];
          final selectedItems = _selectedItems(items);

          if (state.status == CartStatus.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.error && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить корзину',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<CartController>().loadCart(),
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64),
                        SizedBox(height: 12),
                        Text(
                          'Корзина пуста',
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

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<CartController>().loadCart(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final lineTotal = _itemLineTotal(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: item.selectedForPurchase,
                              onChanged: (value) {
                                context.read<CartController>().toggleSelected(
                                  item.cartItemId,
                                  value ?? false,
                                );
                              },
                            ),
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.image_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.price} ${item.currency}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Сумма: ${lineTotal.toStringAsFixed(2)} ${item.currency}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _QtyButton(
                                        icon: Icons.remove,
                                        onTap: () {
                                          context
                                              .read<CartController>()
                                              .decreaseQty(
                                                item.cartItemId,
                                                item.quantity,
                                              );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add,
                                        onTap: () {
                                          context
                                              .read<CartController>()
                                              .increaseQty(
                                                item.cartItemId,
                                                item.quantity,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(item),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Выбрано',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${_selectedCount(items)} шт.',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Итого',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _selectedTotal(items),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: selectedItems.isEmpty
                              ? null
                              : () {
                                  context.push(AppRoutes.buyerCheckout);
                                },
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Перейти к оформлению'),
                        ),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
