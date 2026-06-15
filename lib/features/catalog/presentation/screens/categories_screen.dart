import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Категории'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<CatalogController, CatalogState>(
        builder: (context, state) {
          if (state.status == CatalogStatus.loading && state.categories.isEmpty) {
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = state.categories[index];

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openCategory(context, category),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.categoryName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Открыть товары',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate(delay: (index * 35).ms)
                    .fadeIn(duration: 250.ms)
                    .slideX(begin: 0.05, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}
