import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';

class SellerProductEditScreen extends StatefulWidget {
  const SellerProductEditScreen({super.key, this.product});

  final Map<String, dynamic>? product;

  @override
  State<SellerProductEditScreen> createState() =>
      _SellerProductEditScreenState();
}

class _SellerProductEditScreenState extends State<SellerProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _currencyController = TextEditingController(text: 'BYN');

  final _imagePicker = ImagePicker();

  final Map<int, TextEditingController> _parameterControllers = {};
  final Map<int, int?> _selectedUnitIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSavingImage = false;

  int? _productId;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _subcategoryParameters = [];
  List<Map<String, dynamic>> _measurementUnits = [];
  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    _fillFromInitial();
    _load();
  }

  void _fillFromInitial() {
    final product = widget.product;
    if (product == null) return;

    _productId = int.tryParse(product['product_id']?.toString() ?? '');
    _selectedCategoryId = int.tryParse(
      product['category_id']?.toString() ?? '',
    );
    _selectedSubcategoryId = int.tryParse(
      product['subcategory_id']?.toString() ?? '',
    );
    _nameController.text = (product['name'] ?? '').toString();
    _descriptionController.text = (product['description'] ?? '').toString();
    _priceController.text = (product['price'] ?? '').toString();
    _quantityController.text = (product['quantity'] ?? '').toString();
    _currencyController.text = (product['currency'] ?? 'BYN').toString();
  }

  void _clearParameterControllers() {
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
    _parameterControllers.clear();
    _selectedUnitIds.clear();
  }

  Future<void> _load() async {
    final controller = context.read<SellerController>();

    final categories = await controller.getCategories();
    final measurementUnits = await controller.getMeasurementUnits();

    List<Map<String, dynamic>> subcategories = [];
    List<Map<String, dynamic>> parameters = [];
    List<Map<String, dynamic>> productParameterValues = [];
    List<Map<String, dynamic>> images = [];

    if (_selectedCategoryId != null && _selectedCategoryId! > 0) {
      subcategories = await controller.getSubcategories(_selectedCategoryId!);
    }

    if (_selectedSubcategoryId != null && _selectedSubcategoryId! > 0) {
      parameters = await controller.getSubcategoryParameters(
        categoryId: _selectedCategoryId ?? 0,
        subcategoryId: _selectedSubcategoryId!,
      );
    }

    if (_productId != null && _productId! > 0) {
      images = await controller.getProductImages(_productId!);
      productParameterValues = await controller.getProductParameters(
        _productId!,
      );
    }

    if (!mounted) return;

    _clearParameterControllers();

    final existingValuesByParameterId = <int, String>{};
    final existingUnitsByParameterId = <int, int?>{};

    for (final item in productParameterValues) {
      final parameterId = int.tryParse(item['parameter_id']?.toString() ?? '');
      if (parameterId == null || parameterId <= 0) continue;

      final valueText = item['value_text']?.toString().trim() ?? '';
      existingValuesByParameterId[parameterId] = valueText;

      final unitId = int.tryParse(item['unit_id']?.toString() ?? '');
      existingUnitsByParameterId[parameterId] = unitId;
    }

    for (final parameter in parameters) {
      final parameterId = int.tryParse(
        parameter['parameter_id']?.toString() ?? '',
      );
      if (parameterId == null || parameterId <= 0) continue;

      _parameterControllers[parameterId] = TextEditingController(
        text: existingValuesByParameterId[parameterId] ?? '',
      );
      _selectedUnitIds[parameterId] = existingUnitsByParameterId[parameterId];
    }

    setState(() {
      _categories = categories;
      _subcategories = subcategories;
      _subcategoryParameters = parameters;
      _measurementUnits = measurementUnits;
      _images = images;
      _isLoading = false;
    });
  }

  Future<void> _onCategoryChanged(int? value) async {
    _clearParameterControllers();

    setState(() {
      _selectedCategoryId = value;
      _selectedSubcategoryId = null;
      _subcategories = [];
      _subcategoryParameters = [];
    });

    if (value == null || value <= 0) return;

    final subcategories = await context
        .read<SellerController>()
        .getSubcategories(value);

    if (!mounted) return;

    setState(() {
      _subcategories = subcategories;
    });
  }

  Future<void> _onSubcategoryChanged(int? value) async {
    _clearParameterControllers();

    setState(() {
      _selectedSubcategoryId = value;
      _subcategoryParameters = [];
    });

    if (value == null || value <= 0) return;

    final parameters = await context
        .read<SellerController>()
        .getSubcategoryParameters(
          categoryId: _selectedCategoryId ?? 0,
          subcategoryId: value,
        );

    if (!mounted) return;

    for (final parameter in parameters) {
      final parameterId = int.tryParse(
        parameter['parameter_id']?.toString() ?? '',
      );
      if (parameterId == null || parameterId <= 0) continue;

      _parameterControllers[parameterId] = TextEditingController();
      _selectedUnitIds[parameterId] = null;
    }

    setState(() {
      _subcategoryParameters = parameters;
    });
  }

  List<Map<String, dynamic>> _buildParameterItems() {
    final items = <Map<String, dynamic>>[];

    for (final parameter in _subcategoryParameters) {
      final parameterId =
          int.tryParse(parameter['parameter_id']?.toString() ?? '') ?? 0;
      if (parameterId <= 0) continue;

      final controller = _parameterControllers[parameterId];
      final value = controller?.text.trim() ?? '';
      final unitId = _selectedUnitIds[parameterId];

      if (value.isEmpty) continue;

      items.add({
        'parameter_id': parameterId,
        'value': value,
        'unit_id': unitId,
      });
    }

    return items;
  }

  Future<void> _saveParameters(int productId) async {
    final items = _buildParameterItems();

    await context.read<SellerController>().setProductParameters(
      productId: productId,
      items: items,
    );
  }

  Future<void> _saveBasic() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
      return;
    }

    if (_selectedSubcategoryId == null || _selectedSubcategoryId! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите подкатегорию')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final controller = context.read<SellerController>();

    if (_productId == null) {
      final createdId = await controller.createProduct(
        categoryId: _selectedCategoryId!,
        subcategoryId: _selectedSubcategoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        currency: _currencyController.text.trim(),
      );

      if (!mounted) return;

      if (createdId != null) {
        await _saveParameters(createdId);
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (createdId != null) {
        _productId = createdId;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар создан. Теперь можно добавить изображения'),
          ),
        );

        await _load();
      } else {
        final error = controller.state.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.isNotEmpty == true ? error! : 'Не удалось создать товар',
            ),
          ),
        );
      }

      return;
    }

    final ok = await controller.updateProduct(
      productId: _productId!,
      categoryId: _selectedCategoryId,
      subcategoryId: _selectedSubcategoryId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      currency: _currencyController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      await _saveParameters(_productId!);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Товар обновлён')));
    } else {
      final error = controller.state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true ? error! : 'Не удалось обновить товар',
          ),
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (_productId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сначала сохраните товар')));
      return;
    }

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _isSavingImage = true;
    });

    final ok = await context.read<SellerController>().uploadProductImageFile(
      productId: _productId!,
      file: File(picked.path),
    );

    if (!mounted) return;

    setState(() {
      _isSavingImage = false;
    });

    if (ok) {
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Изображение загружено')));
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true
                ? error!
                : 'Не удалось загрузить изображение',
          ),
        ),
      );
    }
  }

  Future<void> _setMainImage(int imageId) async {
    if (_productId == null) return;

    final ok = await context.read<SellerController>().setMainProductImage(
      productId: _productId!,
      imageId: imageId,
    );

    if (!mounted) return;

    if (ok) {
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Главное изображение выбрано')),
      );
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true
                ? error!
                : 'Не удалось выбрать главное изображение',
          ),
        ),
      );
    }
  }

  Future<void> _deleteImage(int imageId) async {
    if (_productId == null) return;

    final ok = await context.read<SellerController>().deleteProductImage(
      productId: _productId!,
      imageId: imageId,
    );

    if (!mounted) return;

    if (ok) {
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Изображение удалено')));
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true
                ? error!
                : 'Не удалось удалить изображение',
          ),
        ),
      );
    }
  }

  InputDecoration _decoration({required String label, required IconData icon}) {
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

  String _unitName(Map<String, dynamic> item) {
    final short = item['short_name']?.toString().trim() ?? '';
    final name = item['name']?.toString().trim() ?? '';
    if (name.isEmpty && short.isEmpty) return 'Единица';
    if (name.isNotEmpty && short.isNotEmpty) return '$name ($short)';
    return name.isNotEmpty ? name : short;
  }

  @override
  void dispose() {
    _clearParameterControllers();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _productId != null ? 'Редактировать товар' : 'Новый товар';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategoryId,
                        items: _categories.map((category) {
                          final id =
                              int.tryParse(
                                category['category_id'].toString(),
                              ) ??
                              0;
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(_categoryName(category)),
                          );
                        }).toList(),
                        onChanged: _onCategoryChanged,
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
                        initialValue: _selectedSubcategoryId,
                        items: _subcategories.map((subcategory) {
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
                        onChanged: _onSubcategoryChanged,
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
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Заполните поле';
                          }
                          return null;
                        },
                        decoration: _decoration(
                          label: 'Название товара',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: _decoration(
                          label: 'Описание',
                          icon: Icons.description_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim().replaceAll(
                            ',',
                            '.',
                          );
                          if (text.isEmpty) {
                            return 'Заполните поле';
                          }
                          if (double.tryParse(text) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                        decoration: _decoration(
                          label: 'Цена',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
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
                        decoration: _decoration(
                          label: 'Количество',
                          icon: Icons.format_list_numbered,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _currencyController,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Заполните поле';
                          }
                          return null;
                        },
                        decoration: _decoration(
                          label: 'Валюта',
                          icon: Icons.currency_exchange_outlined,
                        ),
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
                          'Количество параметров: ${_subcategoryParameters.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_subcategoryParameters.isNotEmpty) ...[
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
                        ..._subcategoryParameters.map((parameter) {
                          final parameterId =
                              int.tryParse(
                                parameter['parameter_id']?.toString() ?? '',
                              ) ??
                              0;
                          final parameterName =
                              parameter['name']?.toString() ?? 'Параметр';
                          final dataType =
                              parameter['data_type']
                                  ?.toString()
                                  .toLowerCase() ??
                              'text';

                          final controller = _parameterControllers.putIfAbsent(
                            parameterId,
                            () => TextEditingController(),
                          );

                          final selectedUnitId = _selectedUnitIds[parameterId];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                TextFormField(
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
                                  decoration: _decoration(
                                    label: parameterName,
                                    icon: Icons.tune_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int?>(
                                  initialValue: selectedUnitId,
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Без единицы измерения'),
                                    ),
                                    ..._measurementUnits.map((unit) {
                                      final id =
                                          int.tryParse(
                                            unit['unit_id'].toString(),
                                          ) ??
                                          0;
                                      return DropdownMenuItem<int?>(
                                        value: id,
                                        child: Text(_unitName(unit)),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnitIds[parameterId] = value;
                                    });
                                  },
                                  decoration: _decoration(
                                    label: 'Единица измерения',
                                    icon: Icons.straighten,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveBasic,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _productId != null
                                ? 'Сохранить товар'
                                : 'Создать товар',
                          ),
                  ),
                ),
                if (_productId != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Изображения',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (_isSavingImage)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _pickAndUploadImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Из галереи'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _pickAndUploadImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Камера'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  ..._images.map((image) {
                    final imageId =
                        int.tryParse(image['image_id']?.toString() ?? '') ?? 0;
                    final imageUrl = (image['image_url'] ?? '').toString();
                    final sortOrder =
                        int.tryParse(image['sort_order']?.toString() ?? '') ??
                        999;
                    final isMain = sortOrder == 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: imageUrl.isEmpty
                                ? const Icon(Icons.image_not_supported)
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.broken_image_outlined,
                                      );
                                    },
                                  ),
                          ),
                        ),
                        title: Text(
                          imageUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: isMain
                            ? const Text('Главное изображение')
                            : const Text('Можно сделать главным'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isMain)
                              const Icon(Icons.star, color: Colors.amber)
                            else
                              TextButton(
                                onPressed: imageId <= 0
                                    ? null
                                    : () => _setMainImage(imageId),
                                child: const Text('Главная'),
                              ),
                            IconButton(
                              onPressed: imageId <= 0
                                  ? null
                                  : () => _deleteImage(imageId),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
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
