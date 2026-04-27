import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminController>().loadAll();
      if (!mounted) return;
      await context.read<AdminController>().loadProducts();
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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<AdminController>().loadProducts(query: value);
    });
  }

  String _categoryLabel(Map<String, dynamic> item) {
    return item['category_name']?.toString() ??
        item['name']?.toString() ??
        'Категория';
  }

  String _subcategoryLabel(Map<String, dynamic> item) {
    return item['subcategory_name']?.toString() ??
        item['name']?.toString() ??
        'Подкатегория';
  }

  Future<void> _showProductDialog({Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final formKey = GlobalKey<FormState>();

    final state = context.read<AdminController>().state;

    final sellerController = TextEditingController(
      text: product?['seller_id']?.toString() ?? '',
    );
    final nameController = TextEditingController(
      text: product?['name']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?['description']?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: product?['quantity']?.toString() ?? '',
    );
    final currencyController = TextEditingController(
      text: product?['currency']?.toString() ?? 'BYN',
    );

    int? selectedCategoryId = product == null
        ? null
        : int.tryParse(product['category_id'].toString());
    int? selectedSubcategoryId = product == null
        ? null
        : int.tryParse(product['subcategory_id'].toString());

    final parameterControllers = <int, TextEditingController>{};

    if (selectedCategoryId != null && selectedCategoryId > 0) {
      await context.read<AdminController>().loadSubcategoriesByCategory(
        selectedCategoryId,
      );
    }

    if (selectedSubcategoryId != null && selectedSubcategoryId > 0) {
      await context.read<AdminController>().loadProductParametersBySubcategory(
        selectedSubcategoryId,
      );
    }

    final done =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return BlocBuilder<AdminController, AdminState>(
                  builder: (context, state) {
                    final categories = state.categories;
                    final subcategories = state.subcategories;
                    final productParameters = state.productParameters;

                    for (final parameter in productParameters) {
                      final parameterId =
                          int.tryParse(parameter['parameter_id'].toString()) ??
                          0;

                      parameterControllers.putIfAbsent(
                        parameterId,
                        () => TextEditingController(),
                      );
                    }

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
                        child: SingleChildScrollView(
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
                                        ? 'Редактировать товар'
                                        : 'Создать товар',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<int>(
                                  value: selectedCategoryId,
                                  decoration: _dropdownDecoration(
                                    'Категория',
                                    Icons.category_outlined,
                                  ),
                                  items: categories.map((item) {
                                    final id =
                                        int.tryParse(
                                          item['category_id'].toString(),
                                        ) ??
                                        0;
                                    return DropdownMenuItem<int>(
                                      value: id,
                                      child: Text(_categoryLabel(item)),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value <= 0) {
                                      return 'Выберите категорию';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) async {
                                    if (value == null) return;

                                    setModalState(() {
                                      selectedCategoryId = value;
                                      selectedSubcategoryId = null;
                                    });

                                    await context
                                        .read<AdminController>()
                                        .loadSubcategoriesByCategory(value);

                                    emitEmptyParameters(context);
                                  },
                                ),
                                const SizedBox(height: 12),

                                DropdownButtonFormField<int>(
                                  value: selectedSubcategoryId,
                                  decoration: _dropdownDecoration(
                                    'Подкатегория',
                                    Icons.grid_view_rounded,
                                  ),
                                  items: subcategories.map((item) {
                                    final id =
                                        int.tryParse(
                                          (item['subcategory_id'] ??
                                                  item['podcategories_id'])
                                              .toString(),
                                        ) ??
                                        0;
                                    return DropdownMenuItem<int>(
                                      value: id,
                                      child: Text(_subcategoryLabel(item)),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value <= 0) {
                                      return 'Выберите подкатегорию';
                                    }
                                    return null;
                                  },
                                  onChanged: subcategories.isEmpty
                                      ? null
                                      : (value) async {
                                          if (value == null) return;

                                          setModalState(() {
                                            selectedSubcategoryId = value;
                                          });

                                          await context
                                              .read<AdminController>()
                                              .loadProductParametersBySubcategory(
                                                value,
                                              );
                                        },
                                ),
                                const SizedBox(height: 12),

                                _field(
                                  controller: sellerController,
                                  label: 'seller_id',
                                  icon: Icons.storefront_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  controller: nameController,
                                  label: 'Название',
                                  icon: Icons.inventory_2_outlined,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: descriptionController,
                                  minLines: 3,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    labelText: 'Описание',
                                    alignLabelWithHint: true,
                                    prefixIcon: const Icon(
                                      Icons.description_outlined,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  controller: priceController,
                                  label: 'Цена',
                                  icon: Icons.payments_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  controller: quantityController,
                                  label: 'Количество',
                                  icon: Icons.format_list_numbered,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  controller: currencyController,
                                  label: 'Валюта',
                                  icon: Icons.currency_exchange_outlined,
                                ),

                                if (productParameters.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Параметры товара',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...productParameters.map((parameter) {
                                    final parameterId =
                                        int.tryParse(
                                          parameter['parameter_id'].toString(),
                                        ) ??
                                        0;
                                    final parameterName =
                                        parameter['name']?.toString() ??
                                        'Параметр';
                                    final dataType =
                                        parameter['data_type']?.toString() ??
                                        'text';
                                    final unitShortName =
                                        parameter['unit_short_name']
                                            ?.toString() ??
                                        '';

                                    final controller =
                                        parameterControllers[parameterId]!;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType: dataType == 'number'
                                            ? const TextInputType.numberWithOptions(
                                                decimal: true,
                                              )
                                            : TextInputType.text,
                                        validator: (value) {
                                          final text = (value ?? '').trim();
                                          if (text.isEmpty) {
                                            return 'Заполните поле';
                                          }

                                          if (dataType == 'number' &&
                                              double.tryParse(
                                                    text.replaceAll(',', '.'),
                                                  ) ==
                                                  null) {
                                            return 'Введите число';
                                          }

                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: parameterName,
                                          suffixText: unitShortName.isEmpty
                                              ? null
                                              : unitShortName,
                                          prefixIcon: const Icon(
                                            Icons.tune_outlined,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],

                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final categoryId =
                                          selectedCategoryId ?? 0;
                                      final subcategoryId =
                                          selectedSubcategoryId ?? 0;
                                      final sellerId =
                                          int.tryParse(
                                            sellerController.text.trim(),
                                          ) ??
                                          0;
                                      final quantity =
                                          int.tryParse(
                                            quantityController.text.trim(),
                                          ) ??
                                          0;

                                      final parameterValues = productParameters
                                          .map((parameter) {
                                            final parameterId =
                                                int.tryParse(
                                                  parameter['parameter_id']
                                                      .toString(),
                                                ) ??
                                                0;
                                            final dataType =
                                                parameter['data_type']
                                                    ?.toString() ??
                                                'text';
                                            final value =
                                                parameterControllers[parameterId]
                                                    ?.text
                                                    .trim() ??
                                                '';

                                            return {
                                              'parameter_id': parameterId,
                                              'data_type': dataType,
                                              'value': value,
                                            };
                                          })
                                          .where(
                                            (item) =>
                                                item['parameter_id'] != 0 &&
                                                (item['value'] as String)
                                                    .isNotEmpty,
                                          )
                                          .toList();

                                      bool ok;
                                      if (isEdit) {
                                        ok = await context
                                            .read<AdminController>()
                                            .updateProduct(
                                              productId: int.parse(
                                                product['product_id']
                                                    .toString(),
                                              ),
                                              categoryId: categoryId,
                                              subcategoryId: subcategoryId,
                                              sellerId: sellerId,
                                              name: nameController.text.trim(),
                                              description: descriptionController
                                                  .text
                                                  .trim(),
                                              price: priceController.text
                                                  .trim(),
                                              quantity: quantity,
                                              currency: currencyController.text
                                                  .trim(),
                                              parameterValues: parameterValues,
                                            );
                                      } else {
                                        ok = await context
                                            .read<AdminController>()
                                            .createProduct(
                                              categoryId: categoryId,
                                              subcategoryId: subcategoryId,
                                              sellerId: sellerId,
                                              name: nameController.text.trim(),
                                              description: descriptionController
                                                  .text
                                                  .trim(),
                                              price: priceController.text
                                                  .trim(),
                                              quantity: quantity,
                                              currency: currencyController.text
                                                  .trim(),
                                              parameterValues: parameterValues,
                                            );
                                      }

                                      if (!mounted) return;
                                      Navigator.of(sheetContext).pop(ok);
                                    },
                                    child: Text(
                                      isEdit ? 'Сохранить' : 'Создать',
                                    ),
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
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Товар обновлён' : 'Товар создан')),
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

  void emitEmptyParameters(BuildContext context) {
    context.read<AdminController>().emit(
      context.read<AdminController>().state.copyWith(
        productParameters: const [],
      ),
    );
  }

  Future<void> _confirmDelete(int productId, String name) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить товар'),
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

    final ok = await context.read<AdminController>().deleteProduct(productId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Товар удалён' : 'Не удалось удалить товар')),
    );
  }

  static Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return 'Заполните поле';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _reload() async {
    await context.read<AdminController>().loadProducts(
      query: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Товары'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading && state.products.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить товары',
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
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Поиск товара',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<AdminController>().loadProducts();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showProductDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить товар'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.products.isEmpty)
                  const _AdminProductsEmptyBlock(
                    icon: Icons.inventory_2_outlined,
                    text: 'Товаров пока нет',
                  )
                else
                  ...state.products.map((product) {
                    final productId =
                        int.tryParse(product['product_id'].toString()) ?? 0;
                    final name = product['name']?.toString() ?? 'Товар';
                    final price = product['price']?.toString() ?? '0';
                    final currency = product['currency']?.toString() ?? '';
                    final sellerId = product['seller_id']?.toString() ?? '—';
                    final categoryId =
                        product['category_id']?.toString() ?? '—';
                    final subcategoryId =
                        product['subcategory_id']?.toString() ?? '—';
                    final imageUrl = product['main_image']?.toString();

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? const Icon(Icons.image_outlined)
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image_outlined),
                                  ),
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
                                const SizedBox(height: 6),
                                Text(
                                  '$price $currency',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('seller_id: $sellerId'),
                                Text('category_id: $categoryId'),
                                Text('subcategory_id: $subcategoryId'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showProductDialog(product: product),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: productId == 0
                                    ? null
                                    : () => _confirmDelete(productId, name),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
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

class _AdminProductsEmptyBlock extends StatelessWidget {
  const _AdminProductsEmptyBlock({required this.icon, required this.text});

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
