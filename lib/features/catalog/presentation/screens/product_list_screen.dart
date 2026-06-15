import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/app_scaffold.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/core/widgets/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/widgets/filters_sheet_content.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/controllers/favorites_state.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.subcategoryId,
    this.initialQuery = '',
  });

  final String title;
  final int? categoryId;
  final int? subcategoryId;
  final String initialQuery;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<FavoritesController>().loadFavorites();
      await context.read<CatalogController>().selectCategory(
            widget.categoryId,
            subcategoryId: widget.subcategoryId,
          );

      if (widget.initialQuery.trim().isNotEmpty && mounted) {
        await context.read<CatalogController>().search(widget.initialQuery);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<CatalogController>().search(value);
    });
    setState(() {});
  }

  Future<void> _reload() async {
    await context.read<FavoritesController>().loadFavorites();
    await context.read<CatalogController>().selectCategory(
          widget.categoryId,
          subcategoryId: widget.subcategoryId,
        );

    if (_searchController.text.trim().isNotEmpty && mounted) {
      await context.read<CatalogController>().search(_searchController.text);
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<CatalogController>().search('');
  }

  Future<void> _openSortSheet(BuildContext context, CatalogState state) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сортировка',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                _SortTile(
                  title: 'Популярные',
                  icon: Icons.local_fire_department_rounded,
                  selected: state.sortBy == 'popular',
                  onTap: () => Navigator.of(context).pop('popular'),
                ),
                _SortTile(
                  title: 'Выше рейтинг',
                  icon: Icons.star_rounded,
                  selected: state.sortBy == 'rating_desc',
                  onTap: () => Navigator.of(context).pop('rating_desc'),
                ),
                _SortTile(
                  title: 'Сначала дешёвые',
                  icon: Icons.south_rounded,
                  selected: state.sortBy == 'price_asc',
                  onTap: () => Navigator.of(context).pop('price_asc'),
                ),
                _SortTile(
                  title: 'Сначала дорогие',
                  icon: Icons.north_rounded,
                  selected: state.sortBy == 'price_desc',
                  onTap: () => Navigator.of(context).pop('price_desc'),
                ),
                _SortTile(
                  title: 'Сначала новые',
                  icon: Icons.fiber_new_rounded,
                  selected: state.sortBy == 'newest',
                  onTap: () => Navigator.of(context).pop('newest'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      await context.read<CatalogController>().applySort(selected);
    }
  }

  Future<void> _openFiltersSheet(BuildContext context, CatalogState state) async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return FiltersSheetContent(state: state);
      },
    );

    if (!mounted || result == null) return;

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

  String _formatPrice(String price, String currency) => '$price $currency';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.title,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      body: BlocBuilder<CatalogController, CatalogState>(
        builder: (context, state) {
          return Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (value) {
                  _debounce?.cancel();
                  context.read<CatalogController>().search(value);
                  setState(() {});
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSortSheet(context, state),
                      icon: const Icon(Icons.swap_vert_rounded),
                      label: const Text('Сортировка'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFiltersSheet(context, state),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Фильтры'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.status == CatalogStatus.loading &&
                        state.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == CatalogStatus.error &&
                        state.products.isEmpty) {
                      return ErrorView(
                        message:
                            state.errorMessage ?? 'Не удалось загрузить товары',
                        onRetry: _reload,
                      );
                    }

                    if (state.products.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.search_off_rounded,
                                        size: 44,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Товары не найдены',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return BlocBuilder<FavoritesController, FavoritesState>(
                      builder: (context, favoritesState) {
                        return RefreshIndicator(
                          onRefresh: _reload,
                          child: GridView.builder(
                            itemCount: state.products.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 28),
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textMuted,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
