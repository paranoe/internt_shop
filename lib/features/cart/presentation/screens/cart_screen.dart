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

  String _lineTotal(CartItem item) {
    final price = double.tryParse(item.price) ?? 0;
    return (price * item.quantity).toStringAsFixed(2);
  }

  String _allTotal(List<CartItem> items) {
    double total = 0;
    String currency = '';

    for (final item in items) {
      final price = double.tryParse(item.price) ?? 0;
      total += price * item.quantity;
      currency = item.currency;
    }

    return '${total.toStringAsFixed(2)} ${currency.isEmpty ? '' : currency}'
        .trim();
  }

  int _allCount(List<CartItem> items) {
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartController, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];

          if (state.status == CartStatus.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Cart load error',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (items.isEmpty) {
            return const Center(child: Text("Cart empty"));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Price: ${item.price} ${item.currency}"),
                            Text("Qty: ${item.quantity}"),
                            Text("Total: ${_lineTotal(item)} ${item.currency}"),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              context.read<CartController>().increaseQty(
                                item.cartItemId,
                                item.quantity,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              context.read<CartController>().decreaseQty(
                                item.cartItemId,
                                item.quantity,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              context.read<CartController>().deleteItem(
                                item.cartItemId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<CartController, CartState>(
        builder: (context, state) {
          final items = state.cart?.items ?? [];
          if (items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              context.push(AppRoutes.buyerCheckout);
            },
            label: Text('Order ${_allCount(items)} • ${_allTotal(items)}'),
            icon: const Icon(Icons.shopping_bag_outlined),
          );
        },
      ),
    );
  }
}
