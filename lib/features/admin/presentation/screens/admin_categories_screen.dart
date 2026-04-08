import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_subcategories_screen.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminController>().loadCategoriesOnly();
    });
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final isEdit = category != null;
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text:
          category?['category_name']?.toString() ??
          category?['name']?.toString() ??
          '',
    );

    final done =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEdit
                              ? 'Редактировать категорию'
                              : 'Создать категорию',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Название категории',
                          prefixIcon: const Icon(Icons.category_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Введите название категории';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            bool ok;
                            if (isEdit) {
                              ok = await context
                                  .read<AdminController>()
                                  .updateCategory(
                                    categoryId: int.parse(
                                      category['category_id'].toString(),
                                    ),
                                    categoryName: controller.text.trim(),
                                  );
                            } else {
                              ok = await context
                                  .read<AdminController>()
                                  .createCategory(
                                    categoryName: controller.text.trim(),
                                  );
                            }

                            if (!mounted) return;
                            Navigator.of(sheetContext).pop(ok);
                          },
                          child: Text(isEdit ? 'Сохранить' : 'Создать'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Категория обновлена' : 'Категория создана'),
        ),
      );
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _confirmDelete(int categoryId, String categoryName) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить категорию'),
            content: Text('Удалить "$categoryName"?'),
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

    if (!mounted || !confirmed) return;

    final ok = await context.read<AdminController>().deleteCategory(categoryId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Категория удалена' : 'Не удалось удалить категорию',
        ),
      ),
    );
  }

  Future<void> _openSubcategories() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminSubcategoriesScreen()));

    if (!mounted) return;
    await context.read<AdminController>().loadCategoriesOnly();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Категории'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading && state.categories.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить категории',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<AdminController>().loadCategoriesOnly(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showCategoryDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить категорию'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openSubcategories,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: const Text('Перейти к подкатегориям'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.categories.isEmpty)
                  const _AdminCategoriesEmptyBlock(
                    icon: Icons.category_outlined,
                    text: 'Категорий пока нет',
                  )
                else
                  ...state.categories.map((category) {
                    final categoryId =
                        int.tryParse(category['category_id'].toString()) ?? 0;
                    final categoryName =
                        category['category_name']?.toString() ??
                        category['name']?.toString() ??
                        'Категория';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.category_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showCategoryDialog(category: category),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: categoryId == 0
                                ? null
                                : () =>
                                      _confirmDelete(categoryId, categoryName),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminCategoriesEmptyBlock extends StatelessWidget {
  const _AdminCategoriesEmptyBlock({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
