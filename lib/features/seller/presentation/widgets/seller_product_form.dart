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

  String _categoryName(Map<String, dynamic> item) {
    return item['category_name']?.toString() ??
        item['name']?.toString() ??
        'Категория';
  }

  String _subcategoryName(Map<String, dynamic> item) {
    return item['subcategory_name']?.toString() ??
        item['name']?.toString() ??
        'Подкатегория';
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int minLines = 1,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      validator:
          validator ??
          (value) {
            if ((value ?? '').trim().isEmpty) {
              return 'Заполните поле';
            }
            return null;
          },
      decoration: _decoration(label: label, icon: icon, suffixText: suffixText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: selectedCategoryId,
            items: categories.map((category) {
              final id = int.tryParse(category['category_id'].toString()) ?? 0;
              return DropdownMenuItem<int>(
                value: id,
                child: Text(_categoryName(category)),
              );
            }).toList(),
            onChanged: onCategoryChanged,
            validator: (value) {
              if (value == null || value <= 0) {
                return 'Выберите категорию';
              }
              return null;
            },
            decoration: _decoration(
              label: 'Категория',
              icon: Icons.category_outlined,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selectedSubcategoryId,
            items: subcategories.map((subcategory) {
              final id =
                  int.tryParse(
                    (subcategory['subcategory_id'] ??
                            subcategory['podcategories_id'])
                        .toString(),
                  ) ??
                  0;
              return DropdownMenuItem<int>(
                value: id,
                child: Text(_subcategoryName(subcategory)),
              );
            }).toList(),
            onChanged: onSubcategoryChanged,
            validator: (value) {
              if (value == null || value <= 0) {
                return 'Выберите подкатегорию';
              }
              return null;
            },
            decoration: _decoration(
              label: 'Подкатегория',
              icon: Icons.grid_view_rounded,
            ),
          ),
          const SizedBox(height: 12),
          _textField(
            controller: nameController,
            label: 'Название товара',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: descriptionController,
            label: 'Описание',
            icon: Icons.description_outlined,
            minLines: 3,
            maxLines: 5,
            validator: (_) => null,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: priceController,
            label: 'Цена',
            icon: Icons.payments_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final text = (value ?? '').trim().replaceAll(',', '.');
              if (text.isEmpty) {
                return 'Заполните поле';
              }
              if (double.tryParse(text) == null) {
                return 'Введите число';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _textField(
            controller: quantityController,
            label: 'Количество',
            icon: Icons.format_list_numbered,
            keyboardType: TextInputType.number,
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) {
                return 'Заполните поле';
              }
              final number = int.tryParse(text);
              if (number == null || number < 0) {
                return 'Введите число >= 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _textField(
            controller: currencyController,
            label: 'Валюта',
            icon: Icons.currency_exchange_outlined,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Количество параметров: ${parameters.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (parameters.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Параметры товара',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            ...parameters.map((parameter) {
              final parameterId =
                  int.tryParse(parameter['parameter_id'].toString()) ?? 0;
              final parameterName = parameter['name']?.toString() ?? 'Параметр';
              final dataType =
                  parameter['data_type']?.toString().toLowerCase() ?? 'text';
              final unitShortName =
                  parameter['unit_short_name']?.toString() ?? '';

              final controller = parameterControllers.putIfAbsent(
                parameterId,
                () => TextEditingController(),
              );

              final keyboardType = dataType == 'number'
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: (value) {
                    final text = (value ?? '').trim();

                    if (text.isEmpty) {
                      return 'Заполните поле';
                    }

                    if (dataType == 'number' &&
                        double.tryParse(text.replaceAll(',', '.')) == null) {
                      return 'Введите число';
                    }

                    if (dataType == 'boolean') {
                      final normalized = text.toLowerCase();
                      const allowed = ['true', 'false', 'да', 'нет', '1', '0'];
                      if (!allowed.contains(normalized)) {
                        return 'Введите true/false, да/нет или 1/0';
                      }
                    }

                    return null;
                  },
                  decoration: _decoration(
                    label: parameterName,
                    icon: Icons.tune_outlined,
                    suffixText: unitShortName.isEmpty ? null : unitShortName,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
