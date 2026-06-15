import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/utils/price_formatter.dart';
import 'package:diplomeprojectmobile/core/widgets/empty_state_view.dart';
import 'package:diplomeprojectmobile/core/widgets/product_card.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().loadFavorites();
    });
  }

  String _formatPrice(CartItem item) {
    return PriceFormatter.format(item.price, currency: item.currency);
  }

  Future<void> _confirmDelete(CartItem item) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text('Удалить из избранного'),
            content: Text('Удалить «${item.productName}» из избранного?'),
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
    await context.read<FavoritesController>().removeFavorite(item.productId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Избранное'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<FavoritesController, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoritesStatus.error && state.items.isEmpty) {
            return _FavoritesErrorView(
              message: state.errorMessage ?? 'Не удалось загрузить избранное',
              onRetry: () => context.read<FavoritesController>().loadFavorites(),
            );
          }

          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<FavoritesController>().loadFavorites(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: const [
                  SizedBox(height: 120),
                  EmptyStateView(
                    icon: Icons.favorite_border_rounded,
                    title: 'Избранное пусто',
                    subtitle: 'Добавляйте товары, чтобы быстро находить их позже.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FavoritesController>().loadFavorites(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Избранные товары',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Text(
                            '${state.items.length}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.56,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = state.items[index];

                        return ProductCard(
                          title: item.productName,
                          price: _formatPrice(item),
                          imageUrl: item.mainImage,
                          isFavorite: true,
                          onTap: () {
                            context.push(
                              '${AppRoutes.buyerProductDetails}?id=${item.productId}',
                            );
                          },
                          onFavoriteTap: () => _confirmDelete(item),
                        );
                      },
                      childCount: state.items.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  const _FavoritesErrorView({required this.message, required this.onRetry});

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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
