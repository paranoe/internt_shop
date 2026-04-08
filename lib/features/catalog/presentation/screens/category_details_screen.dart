import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/subcategory.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  Future<void> _reload() async {
    await context.read<CatalogController>().loadSubcategories(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: Text(widget.categoryName), centerTitle: true),
      body: BlocBuilder<CatalogController, CatalogState>(
        builder: (context, state) {
          if (state.status == CatalogStatus.loading &&
              state.subcategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CatalogStatus.error &&
              state.subcategories.isEmpty) {
            return ErrorView(
              message:
                  state.errorMessage ?? 'Не удалось загрузить подкатегории',
              onRetry: _reload,
            );
          }

          if (state.subcategories.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Подкатегории пока не найдены')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.subcategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final subcategory = state.subcategories[index];

                return _SubcategoryItem(
                  subcategory: subcategory,
                  categoryId: widget.categoryId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SubcategoryItem extends StatelessWidget {
  const _SubcategoryItem({required this.subcategory, required this.categoryId});

  final Subcategory subcategory;
  final int categoryId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          subcategory.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push(
            '${AppRoutes.buyerProducts}?category_id=$categoryId&subcategory_id=${subcategory.subcategoryId}&title=${Uri.encodeComponent(subcategory.name)}',
          );
        },
      ),
    );
  }
}
