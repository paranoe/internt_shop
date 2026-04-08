import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/core/widgets/shimmer_loader.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(String price, String currency) {
    return '$price $currency';
  }

  Future<void> _reload() async {
    final query = _searchController.text.trim();

    await context.read<FavoritesController>().loadFavorites();

    if (query.isNotEmpty) {
      await context.read<CatalogController>().search(query);
      return;
    }

    await context.read<CatalogController>().loadHome();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<CatalogController>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<FavoritesController, FavoritesState>(
              listener: (context, state) {},
            ),
          ],
          child: BlocBuilder<CatalogController, CatalogState>(
            builder: (context, state) {
              if (state.status == CatalogStatus.loading &&
                  state.products.isEmpty &&
                  state.categories.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  children: const [
                    ShimmerLoader(height: 56, radius: 18),
                    SizedBox(height: 10),
                    ShimmerLoader(height: 250, radius: 18),
                  ],
                );
              }

              if (state.status == CatalogStatus.error &&
                  state.products.isEmpty &&
                  state.categories.isEmpty) {
                return ErrorView(
                  message: state.errorMessage ?? 'Не удалось загрузить товары',
                  onRetry: () => context.read<CatalogController>().loadHome(),
                );
              }

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  children: [
                    TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        context.read<CatalogController>().search(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Поиск товаров',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Все товары',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (state.products.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 40,
                              color: Colors.black45,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Товары не найдены',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Попробуйте изменить запрос или обновить экран.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      BlocBuilder<FavoritesController, FavoritesState>(
                        builder: (context, favoritesState) {
                          return GridView.builder(
                            itemCount: state.products.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                  mainAxisExtent: 245,
                                ),
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              final isFavorite = context
                                  .read<FavoritesController>()
                                  .isFavorite(product.productId);

                              return _HomeProductCard(
                                productId: product.productId,
                                title: product.name,
                                price: _formatPrice(
                                  product.price,
                                  product.currency,
                                ),
                                imageUrl: product.mainImage,
                                isFavorite: isFavorite,
                                onTap: () {
                                  context.push(
                                    '${AppRoutes.buyerProductDetails}?id=${product.productId}',
                                  );
                                },
                                onFavoriteTap: () async {
                                  await context
                                      .read<FavoritesController>()
                                      .toggleFavorite(product.productId);
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
    required this.productId,
    required this.title,
    required this.price,
    required this.isFavorite,
    this.imageUrl,
    this.onTap,
    this.onFavoriteTap,
  });

  final int productId;
  final String title;
  final String price;
  final String? imageUrl;
  final bool isFavorite;
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
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 24,
                          shadows: const [
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
