import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/core/widgets/app_scaffold.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_state.dart';
import 'package:diplomeprojectmobile/features/product/presentation/controllers/product_controller.dart';
import 'package:diplomeprojectmobile/features/product/presentation/controllers/product_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().load(widget.productId);
      context.read<CartController>().loadCart();
    });
  }

  CartItem? _findCartItem(CartState state) {
    final items = state.cart?.items ?? [];
    try {
      return items.firstWhere((e) => e.productId == widget.productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isBusy = true);

    try {
      await context.read<CartController>().addItem(
        productId: widget.productId,
        quantity: 1,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Товар добавлен в корзину')));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось добавить товар в корзину')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _increase(CartItem item) async {
    setState(() => _isBusy = true);

    try {
      await context.read<CartController>().increaseQty(
        item.cartItemId,
        item.quantity,
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _decrease(CartItem item) async {
    setState(() => _isBusy = true);

    try {
      await context.read<CartController>().decreaseQty(
        item.cartItemId,
        item.quantity,
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  String _price(String value, String currency) => '$value $currency';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Товар',
      body: BlocBuilder<ProductController, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading && state.details == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductStatus.error || state.details == null) {
            return ErrorView(
              message: state.errorMessage ?? 'Не удалось загрузить товар',
              onRetry: () =>
                  context.read<ProductController>().load(widget.productId),
            );
          }

          final product = state.details!;
          final images = state.images;
          final parameters = state.parameters;
          final reviews = state.reviews;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: images.isEmpty
                          ? const Center(
                              child: Icon(Icons.image_outlined, size: 56),
                            )
                          : PageView.builder(
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.network(
                                    images[index].imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 56,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _price(product.price, product.currency),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((product.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Описание',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(product.description!),
                    ],
                    if (parameters.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Характеристики',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: parameters
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(p.name)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            p.value,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Отзывы',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (reviews.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Пока нет отзывов'),
                        ),
                      )
                    else
                      ...reviews
                          .take(3)
                          .map(
                            (r) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.buyerName?.isNotEmpty == true
                                          ? r.buyerName!
                                          : 'Покупатель',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Оценка: ${r.rating}/5'),
                                    if ((r.comment ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(r.comment!),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: BlocBuilder<CartController, CartState>(
                    builder: (context, cartState) {
                      final cartItem = _findCartItem(cartState);

                      if (cartItem == null) {
                        return ElevatedButton(
                          onPressed: _isBusy ? null : _addToCart,
                          child: _isBusy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('В корзину'),
                        );
                      }

                      return Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _isBusy
                                  ? null
                                  : () => _decrease(cartItem),
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _isBusy
                                  ? null
                                  : () => _increase(cartItem),
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
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
