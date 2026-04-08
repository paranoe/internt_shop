import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminSubcategoriesScreen extends StatefulWidget {
  const AdminSubcategoriesScreen({super.key});

  @override
  State<AdminSubcategoriesScreen> createState() =>
      _AdminSubcategoriesScreenState();
}

class _AdminSubcategoriesScreenState extends State<AdminSubcategoriesScreen> {
  int? _selectedCategoryIdFilter;

  String _categoryLabel(Map<String, dynamic> category) {
    return category['category_name']?.toString() ??
        category['name']?.toString() ??
        'Категория';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminController>().loadCategoriesOnly();
      if (!mounted) return;
      await context.read<AdminController>().loadAdminSubcategories();
    });
  }

  Future<void> _showSubcategoryDialog({
    Map<String, dynamic>? subcategory,
  }) async {
    final state = context.read<AdminController>().state;
    final isEdit = subcategory != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: subcategory?['name']?.toString() ?? '',
    );

    int? selectedCategoryId = isEdit
        ? int.tryParse(subcategory!['category_id'].toString())
        : null;

    final done =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
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
                      child: SingleChildScrollView(
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
                                    ? 'Редактировать подкатегорию'
                                    : 'Создать подкатегорию',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Название подкатегории',
                                prefixIcon: const Icon(Icons.grid_view_rounded),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Введите название подкатегории';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: 'Категория',
                                prefixIcon: const Icon(Icons.category_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: state.categories.map((category) {
                                final categoryId =
                                    int.tryParse(
                                      category['category_id'].toString(),
                                    ) ??
                                    0;
                                return DropdownMenuItem<int>(
                                  value: categoryId,
                                  child: Text(_categoryLabel(category)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  selectedCategoryId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value <= 0) {
                                  return 'Выберите категорию';
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
                                        .updateSubcategory(
                                          subcategoryId: int.parse(
                                            subcategory['subcategory_id']
                                                .toString(),
                                          ),
                                          name: nameController.text.trim(),
                                          categoryId: selectedCategoryId!,
                                        );
                                  } else {
                                    ok = await context
                                        .read<AdminController>()
                                        .createSubcategory(
                                          name: nameController.text.trim(),
                                          categoryId: selectedCategoryId!,
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
                  ),
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Подкатегория обновлена' : 'Подкатегория создана',
          ),
        ),
      );
      await _reload();
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _confirmDelete(int subcategoryId, String name) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить подкатегорию'),
            content: Text('Удалить "$name"?'),
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

    final ok = await context.read<AdminController>().deleteSubcategory(
      subcategoryId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Подкатегория удалена' : 'Не удалось удалить подкатегорию',
        ),
      ),
    );

    if (ok) {
      await _reload();
    }
  }

  Future<void> _reload() async {
    await context.read<AdminController>().loadCategoriesOnly();
    if (!mounted) return;
    await context.read<AdminController>().loadAdminSubcategories(
      categoryId: _selectedCategoryIdFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Подкатегории'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading &&
              state.adminSubcategories.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error &&
              state.adminSubcategories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить подкатегории',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int?>(
                  value: _selectedCategoryIdFilter,
                  decoration: InputDecoration(
                    labelText: 'Фильтр по категории',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Все категории'),
                    ),
                    ...state.categories.map((category) {
                      final categoryId =
                          int.tryParse(category['category_id'].toString()) ?? 0;
                      return DropdownMenuItem<int?>(
                        value: categoryId,
                        child: Text(_categoryLabel(category)),
                      );
                    }),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedCategoryIdFilter = value;
                    });
                    await context
                        .read<AdminController>()
                        .loadAdminSubcategories(categoryId: value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showSubcategoryDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить подкатегорию'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.adminSubcategories.isEmpty)
                  const _AdminSubcategoriesEmptyBlock(
                    icon: Icons.grid_view_rounded,
                    text: 'Подкатегорий пока нет',
                  )
                else
                  ...state.adminSubcategories.map((subcategory) {
                    final subcategoryId =
                        int.tryParse(
                          subcategory['subcategory_id'].toString(),
                        ) ??
                        0;
                    final name =
                        subcategory['name']?.toString() ?? 'Подкатегория';
                    final categoryName =
                        subcategory['category_name']?.toString() ??
                        subcategory['category']?.toString() ??
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
                              color: Colors.orange.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.grid_view_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  categoryName,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showSubcategoryDialog(
                              subcategory: subcategory,
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: subcategoryId == 0
                                ? null
                                : () => _confirmDelete(subcategoryId, name),
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

class _AdminSubcategoriesEmptyBlock extends StatelessWidget {
  const _AdminSubcategoriesEmptyBlock({required this.icon, required this.text});

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
