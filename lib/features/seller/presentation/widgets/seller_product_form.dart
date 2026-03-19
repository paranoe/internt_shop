import 'package:flutter/material.dart';

class SellerProductForm extends StatelessWidget {
  const SellerProductForm({
    super.key,
    required this.formKey,
    required this.groupItems,
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    required this.currencyController,
  });

  final GlobalKey<FormState> formKey;

  final List<String> groupItems;
  final String? selectedGroup;
  final ValueChanged<String?> onGroupChanged;

  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController currencyController;

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedGroup,
            items: groupItems
                .map(
                  (group) => DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  ),
                )
                .toList(),
            onChanged: onGroupChanged,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Группа категории',
              prefixIcon: Icon(Icons.dashboard_customize_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Выберите группу категории';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}
