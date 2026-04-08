import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/core/widgets/error_view.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CatalogController>();
      if (controller.state.categories.isEmpty) {
        controller.loadHome();
      }
    });
  }

  void _openCategory(BuildContext context, Category category) {
    context.push(
      '${AppRoutes.buyerCategoryDetails}?category_id=${category.categoryId}&title=${Uri.encodeComponent(category.categoryName)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Категории'), centerTitle: true),
      body: BlocBuilder<CatalogController, CatalogState>(
        builder: (context, state) {
          if (state.status == CatalogStatus.loading &&
              state.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CatalogStatus.error && state.categories.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Не удалось загрузить категории',
              onRetry: () => context.read<CatalogController>().loadHome(),
            );
          }

          if (state.categories.isEmpty) {
            return const Center(child: Text('Категории пока не найдены'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CatalogController>().loadHome(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = state.categories[index];

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      category.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openCategory(context, category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
