import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/core/widgets/app_scaffold.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/core/widgets/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';
import 'package:go_router/go_router.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.title, this.categoryId});

  final String title;
  final int? categoryId;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogController>().selectCategory(widget.categoryId);
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            onSubmitted: (value) {
              context.read<CatalogController>().search(value);
            },
            decoration: InputDecoration(
              hintText: 'Поиск товаров',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  context.read<CatalogController>().selectCategory(
                    widget.categoryId,
                  );
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<CatalogController, CatalogState>(
              builder: (context, state) {
                if (state.status == CatalogStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == CatalogStatus.error) {
                  return ErrorView(
                    message:
                        state.errorMessage ?? 'Не удалось загрузить товары',
                    onRetry: () {
                      context.read<CatalogController>().selectCategory(
                        widget.categoryId,
                      );
                    },
                  );
                }

                if (state.products.isEmpty) {
                  return const Center(child: Text('Товары не найдены'));
                }

                return GridView.builder(
                  itemCount: state.products.length,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
