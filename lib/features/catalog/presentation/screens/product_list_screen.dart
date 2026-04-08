import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/app_scaffold.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Сортировка',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                _SortTile(
                  title: 'Популярные',
                  selected: state.sortBy == 'popular',
                  onTap: () => Navigator.of(context).pop('popular'),
                ),
                _SortTile(
                  title: 'Выше рейтинг',
                  selected: state.sortBy == 'rating_desc',
                  onTap: () => Navigator.of(context).pop('rating_desc'),
                ),
                _SortTile(
                  title: 'Сначала дешёвые',
                  selected: state.sortBy == 'price_asc',
                  onTap: () => Navigator.of(context).pop('price_asc'),
                ),
                _SortTile(
                  title: 'Сначала дорогие',
                  selected: state.sortBy == 'price_desc',
                  onTap: () => Navigator.of(context).pop('price_desc'),
                ),
                _SortTile(
                  title: 'Сначала новые',
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

  Future<void> _openFiltersSheet(
    BuildContext context,
    CatalogState state,
  ) async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return _FiltersSheetContent(state: state);
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

  String _formatPrice(String price, String currency) {
    return '$price $currency';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.title,
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
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSortSheet(context, state),
                      icon: const Icon(Icons.swap_vert_rounded),
                      label: const Text('Сортировка'),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.search_off_rounded,
                                        size: 44,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Товары не найдены',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Попробуй изменить запрос, сортировку или фильтры.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.black54),
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

                              return _CatalogProductCard(
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

class _FiltersSheetContent extends StatefulWidget {
  const _FiltersSheetContent({required this.state});

  final CatalogState state;

  @override
  State<_FiltersSheetContent> createState() => _FiltersSheetContentState();
}

class _FiltersSheetContentState extends State<_FiltersSheetContent> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late double? _selectedRating;
  late Map<int, String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(text: widget.state.minPrice);
    _maxPriceController = TextEditingController(text: widget.state.maxPrice);
    _selectedRating = widget.state.minRating;
    _selectedValues = Map<int, String>.from(widget.state.parameterFilters);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text('Цена', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'От'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'До'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Рейтинг',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('4+'),
                    selected: _selectedRating == 4.0,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 4.0 ? null : 4.0;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('4.5+'),
                    selected: _selectedRating == 4.5,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 4.5 ? null : 4.5;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('5'),
                    selected: _selectedRating == 5.0,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 5.0 ? null : 5.0;
                      });
                    },
                  ),
                ],
              ),
              if (state.selectedSubcategoryId != null &&
                  state.availableParameters.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Параметры товара',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...state.availableParameters.map((parameter) {
                  final parameterId =
                      int.tryParse(
                        (parameter['parameter_id'] ?? '').toString(),
                      ) ??
                      0;
                  final name = (parameter['name'] ?? 'Параметр').toString();
                  final values =
                      (parameter['values'] as List<dynamic>? ?? const [])
                          .map((e) => e.toString())
                          .toList();

                  if (values.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: values.map((value) {
                            final selected =
                                _selectedValues[parameterId] == value;

                            return ChoiceChip(
                              label: Text(value),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  if (selected) {
                                    _selectedValues.remove(parameterId);
                                  } else {
                                    _selectedValues[parameterId] = value;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(const _FilterResult.clear());
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _FilterResult.apply(
                            minPrice: _minPriceController.text.trim(),
                            maxPrice: _maxPriceController.text.trim(),
                            minRating: _selectedRating,
                            parameterFilters: _selectedValues,
                          ),
                        );
                      },
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
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

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _FilterResult {
  const _FilterResult.apply({
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.parameterFilters,
  }) : clear = false;

  const _FilterResult.clear()
    : minPrice = '',
      maxPrice = '',
      minRating = null,
      parameterFilters = const {},
      clear = true;

  final String minPrice;
  final String maxPrice;
  final double? minRating;
  final Map<int, String> parameterFilters;
  final bool clear;
}
