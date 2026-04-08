import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_state.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_state.dart';
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
  bool _isFavoriteBusy = false;
  int _currentImage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().load(widget.productId);
      context.read<CartController>().loadCart();
      context.read<FavoritesController>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  CartItem? _findCartItem(CartState state) {
    final items = state.cart?.items ?? [];
    try {
      return items.firstWhere((e) => e.productId == widget.productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _reloadProduct() async {
    await context.read<ProductController>().load(widget.productId);
    await context.read<CartController>().loadCart();
    await context.read<FavoritesController>().loadFavorites();
  }

  Future<void> _addToCart() async {
    setState(() => _isBusy = true);

    try {
      await context.read<CartController>().addItem(
        productId: widget.productId,
        quantity: 1,
      );
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

  Future<void> _toggleFavorite() async {
    if (_isFavoriteBusy) return;

    setState(() => _isFavoriteBusy = true);

    try {
      await context.read<FavoritesController>().toggleFavorite(
        widget.productId,
      );
    } finally {
      if (mounted) {
        setState(() => _isFavoriteBusy = false);
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
      await context.read<CartController>().decreaseOrRemoveFromProduct(
        item.cartItemId,
        item.quantity,
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _openImageViewer(List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String _price(String value, String currency) => '$value $currency';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductController, ProductState>(
      builder: (context, state) {
        final productTitle = state.details?.name ?? 'Товар';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: Text(
              productTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<FavoritesController, FavoritesState>(
                builder: (context, favoritesState) {
                  final isFavorite = context
                      .read<FavoritesController>()
                      .isFavorite(widget.productId);

                  return IconButton(
                    onPressed: _isFavoriteBusy ? null : _toggleFavorite,
                    icon: _isFavoriteBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? Colors.red : null,
                          ),
                  );
                },
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state.status == ProductStatus.loading &&
                  state.details == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ProductStatus.error ||
                  state.details == null) {
                return ErrorView(
                  message: state.errorMessage ?? 'Не удалось загрузить товар',
                  onRetry: _reloadProduct,
                );
              }

              final product = state.details!;
              final images = state.images;
              final imageUrls = images.map((e) => e.imageUrl).toList();
              final reviews = state.reviews;

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _reloadProduct,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 360,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (images.isEmpty)
                                  Container(
                                    color: AppColors.surfaceSecondary,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 64,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  )
                                else
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: images.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImage = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          _openImageViewer(imageUrls, index);
                                        },
                                        child: Image.network(
                                          images[index].imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color:
                                                    AppColors.surfaceSecondary,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    size: 56,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                if (images.length > 1)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 14,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        images.length,
                                        (index) => AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: _currentImage == index
                                              ? 18
                                              : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _currentImage == index
                                                ? Colors.black87
                                                : Colors.black26,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Text(
                              _price(product.price, product.currency),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if ((product.description ?? '')
                              .trim()
                              .isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                              child: Text(
                                'Описание',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: Text(
                                product.description!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      height: 1.45,
                                      color: Colors.black87,
                                    ),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Отзывы',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (reviews.isEmpty)
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text('Пока нет отзывов'),
                            )
                          else
                            ...reviews.map(
                              (r) => Container(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
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
                                      r.buyerName?.isNotEmpty == true
                                          ? r.buyerName!
                                          : 'Покупатель',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < r.rating
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    if ((r.comment ?? '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        r.comment!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: BlocBuilder<CartController, CartState>(
                        builder: (context, cartState) {
                          final cartItem = _findCartItem(cartState);

                          if (cartItem == null) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
                              ),
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
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
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
      },
    );
  }
}

class _FullscreenImageViewer extends StatefulWidget {
  const _FullscreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (widget.imageUrls.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
