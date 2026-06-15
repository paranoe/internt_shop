import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/utils/price_formatter.dart';
import 'package:diplomeprojectmobile/core/widgets/empty_state_view.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/shared/widgets/auth_required.dart';

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
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить из избранного'),
            content: Text('Удалить "${item.productName}" из избранного?'),
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

    final isAuth =
        context.read<AuthController>().state.status == AuthStatus.authenticated;

    if (!isAuth) {
      context.push('/login');
      return;
    }

    if (!mounted || !confirmed) return;
    await context.read<FavoritesController>().removeFavorite(item.productId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuth =
        context.watch<AuthController>().state.status ==
        AuthStatus.authenticated;

    if (!isAuth) {
      return const AuthRequired(
        title: 'Избранное недоступно',
        subtitle: 'Войдите, чтобы сохранять товары',
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Избранное'), centerTitle: true),
      body: BlocBuilder<FavoritesController, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoritesStatus.error && state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ?? 'Не удалось загрузить избранное',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<FavoritesController>().loadFavorites();
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<FavoritesController>().loadFavorites(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
                children: const [
                  SizedBox(height: 120),
                  EmptyStateView(
                    icon: Icons.favorite_border_rounded,
                    title: 'Избранное пусто',
                    subtitle:
                        'Добавляйте товары, чтобы быстро находить их позже.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<FavoritesController>().loadFavorites(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Избранные товары',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GridView.builder(
                  itemCount: state.items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    mainAxisExtent: 245,
                  ),
                  itemBuilder: (context, index) {
                    final item = state.items[index];

                    return _FavoriteProductCard(
                      title: item.productName,
                      price: _formatPrice(item),
                      imageUrl: item.mainImage,
                      onTap: () {
                        context.push(
                          '${AppRoutes.buyerProductDetails}?id=${item.productId}',
                        );
                      },
                      onFavoriteTap: () => _confirmDelete(item),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  const _FavoriteProductCard({
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.onFavoriteTap,
  });

  final String title;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
              Stack(
                children: [
                  SizedBox(
                    height: 165,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Container(
                        color: AppColors.surfaceSecondary,
                        child: imageUrl == null || imageUrl!.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.textMuted,
                                  size: 34,
                                ),
                              )
                            : Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.textMuted,
                                    size: 34,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: onFavoriteTap,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 24,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
