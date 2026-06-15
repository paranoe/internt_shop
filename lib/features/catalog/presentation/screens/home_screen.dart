import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/core/widgets/product_card.dart';
import 'package:diplomeprojectmobile/core/widgets/shimmer_loader.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/widgets/filters_sheet_content.dart';
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

  String _formatPrice(String price, String currency) => '$price $currency';

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

  Future<void> _openFiltersSheet(BuildContext context) async {
    final catalogState = context.read<CatalogController>().state;
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return FiltersSheetContent(state: catalogState);
      },
    );

    if (!context.mounted || result == null) return;

    if (result.clear) {
      await context.read<CatalogController>().clearFilters();
      return;
    }

    await context.read<CatalogController>().applyFilters(
          minPrice: result.minPrice,
          maxPrice: result.maxPrice,
          minRating: result.minRating,
          parameterFilters: result.parameterFilters,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: BlocBuilder<CatalogController, CatalogState>(
          builder: (context, state) {
            if (state.status == CatalogStatus.loading &&
                state.products.isEmpty &&
                state.categories.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: const [
                  ShimmerLoader(height: 142, radius: 28),
                  SizedBox(height: 14),
                  ShimmerLoader(height: 56, radius: 22),
                  SizedBox(height: 14),
                  ShimmerLoader(height: 280, radius: 24),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (value) {
                      context.read<CatalogController>().search(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Поиск товаров',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  if (state.availableParameters.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openFiltersSheet(context),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Фильтры'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (state.products.isEmpty)
                    const _EmptyProductsCard()
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
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 8,
                            mainAxisExtent: 306,
                          ),
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            final isFavorite = context
                                .read<FavoritesController>()
                                .isFavorite(product.productId);

                            return ProductCard(
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
    );
  }
}

class _EmptyProductsCard extends StatelessWidget {
  const _EmptyProductsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 44,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'Товары не найдены',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),

        ],
      ),
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.96, 0.96));
  }
}
