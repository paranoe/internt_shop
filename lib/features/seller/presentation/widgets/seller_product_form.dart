import 'package:flutter/material.dart';

class SellerProductForm extends StatelessWidget {
  const SellerProductForm({
    super.key,
    required this.formKey,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onSubcategoryChanged,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    required this.currencyController,
    required this.parameters,
    required this.parameterControllers,
  });

  final GlobalKey<FormState> formKey;

  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;

  final List<Map<String, dynamic>> subcategories;
  final int? selectedSubcategoryId;
  final ValueChanged<int?> onSubcategoryChanged;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController currencyController;

  final List<Map<String, dynamic>> parameters;
  final Map<int, TextEditingController> parameterControllers;

  int _categoryId(Map<String, dynamic> item) {
    return int.tryParse((item['category_id'] ?? item['id'] ?? '').toString()) ??
        0;
  }

  String _categoryName(Map<String, dynamic> item) {
    return (item['category_name'] ??
            item['name'] ??
            item['title'] ??
            'Категория')
        .toString();
  }

  int _subcategoryId(Map<String, dynamic> item) {
    return int.tryParse(
          (item['subcategory_id'] ?? item['id'] ?? '').toString(),
        ) ??
        0;
  }

  String _subcategoryName(Map<String, dynamic> item) {
    return (item['subcategory_name'] ??
            item['name'] ??
            item['title'] ??
            'Подкатегория')
        .toString();
  }

  String _parameterName(Map<String, dynamic> item) {
    return (item['name'] ?? 'Параметр').toString();
  }

  String _parameterType(Map<String, dynamic> item) {
    return (item['data_type'] ?? 'text').toString();
  }

  bool _isRequired(Map<String, dynamic> item) {
    return item['is_required'] == true;
  }

  int _parameterId(Map<String, dynamic> item) {
    return int.tryParse((item['parameter_id'] ?? '').toString()) ?? 0;
  }

  IconData _iconByType(String type) {
    final value = type.toLowerCase();

    if (value == 'number') return Icons.pin_outlined;
    if (value == 'boolean') return Icons.toggle_on_outlined;

    return Icons.tune_outlined;
  }

  TextInputType _keyboardByType(String type) {
    final value = type.toLowerCase();
    if (value == 'number') {
      return const TextInputType.numberWithOptions(decimal: true);
    }
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: selectedCategoryId,
            items: categories
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: _categoryId(item),
                    child: Text(_categoryName(item)),
                  ),
                )
                .toList(),
            onChanged: onCategoryChanged,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Категория',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            validator: (value) {
              if (value == null || value <= 0) {
                return 'Выберите категорию';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selectedSubcategoryId,
            items: subcategories
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: _subcategoryId(item),
                    child: Text(_subcategoryName(item)),
                  ),
                )
                .toList(),
            onChanged: subcategories.isEmpty ? null : onSubcategoryChanged,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Подкатегория',
              prefixIcon: Icon(Icons.grid_view_rounded),
            ),
            validator: (value) {
              if (value == null || value <= 0) {
                return 'Выберите подкатегорию';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Название товара',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return 'Введите название';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Описание',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Цена',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            validator: (value) {
              final raw = (value ?? '').trim().replaceAll(',', '.');
              if (raw.isEmpty) return 'Введите цену';
              final parsed = num.tryParse(raw);
              if (parsed == null || parsed < 0) {
                return 'Введите корректную цену';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Количество',
              prefixIcon: Icon(Icons.inventory_outlined),
            ),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Введите количество';
              final parsed = int.tryParse(raw);
              if (parsed == null || parsed < 0) {
                return 'Введите корректное количество';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: currencyController,
            decoration: const InputDecoration(
              labelText: 'Валюта',
              prefixIcon: Icon(Icons.currency_exchange_outlined),
            ),
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return 'Введите валюту';
              return null;
            },
          ),
          if (selectedSubcategoryId != null) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Параметры подкатегории',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            if (parameters.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Для этой подкатегории параметры пока не заданы',
                ),
              )
            else
              ...parameters.map((parameter) {
                final parameterId = _parameterId(parameter);
                final controller = parameterControllers.putIfAbsent(
                  parameterId,
                  () => TextEditingController(),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: _keyboardByType(_parameterType(parameter)),
                    decoration: InputDecoration(
                      labelText: _isRequired(parameter)
                          ? '${_parameterName(parameter)} *'
                          : _parameterName(parameter),
                      hintText: 'Тип: ${_parameterType(parameter)}',
                      prefixIcon: Icon(_iconByType(_parameterType(parameter))),
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();

                      if (_isRequired(parameter) && text.isEmpty) {
                        return 'Заполните поле';
                      }

                      if (_parameterType(parameter).toLowerCase() == 'number' &&
                          text.isNotEmpty &&
                          num.tryParse(text.replaceAll(',', '.')) == null) {
                        return 'Введите число';
                      }

                      return null;
                    },
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}
