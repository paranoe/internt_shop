import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/widgets/app_scaffold.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/core/widgets/product_card.dart';
import 'package:diplomeprojectmobile/core/widgets/shimmer_loader.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatPrice(String price, String currency) {
    return '$price $currency';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      body: BlocBuilder<CatalogController, CatalogState>(
        builder: (context, state) {
          if (state.status == CatalogStatus.loading &&
              state.categories.isEmpty &&
              state.products.isEmpty) {
            return ListView(
              children: const [
                ShimmerLoader(height: 160, radius: 28),
                SizedBox(height: 20),
                ShimmerLoader(height: 42, radius: 18),
                SizedBox(height: 20),
                ShimmerLoader(height: 260, radius: 24),
              ],
            );
          }

          if (state.status == CatalogStatus.error &&
              state.categories.isEmpty &&
              state.products.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Не удалось загрузить каталог',
              onRetry: () => context.read<CatalogController>().loadHome(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CatalogController>().loadHome(),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DefaultTextStyle(
                          style: const TextStyle(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Найдите всё, что нужно',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Каталог товаров, корзина, оформление заказа и доставка в одном приложении.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Категории',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];

                      return ActionChip(
                        label: Text(category.categoryName),
                        onPressed: () {
                          context.push(
                            '${AppRoutes.buyerProducts}?category_id=${category.categoryId}&title=${Uri.encodeComponent(category.categoryName)}',
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Популярные товары',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(
                          '${AppRoutes.buyerProducts}?title=Все товары',
                        );
                      },
                      child: const Text('Смотреть все'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: state.products.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = state.products[index];

                    return ProductCard(
                      title: product.name,
                      subtitle: 'ID: ${product.productId}',
                      price: _formatPrice(product.price, product.currency),
                      imageUrl: product.mainImage,
                      onTap: () {
                        context.push(
                          '${AppRoutes.buyerProductDetails}?id=${product.productId}',
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
    );
  }
}
