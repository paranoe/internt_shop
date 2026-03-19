import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/widgets/seller_product_form.dart';

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

  final _imageUrlController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '1');

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSavingImage = false;

  int? _productId;
  int? _selectedCategoryId;
  String? _selectedGroup;

  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  List<Map<String, dynamic>> _images = [];

  static const Map<String, List<String>> _categoryGroups = {
    'Электроника': [
      'Смартфоны',
      'Ноутбуки',
      'Планшеты',
      'Наушники',
      'Умные часы',
    ],
    'Одежда и обувь': [
      'Женская одежда',
      'Мужская одежда',
      'Обувь',
      'Сумки',
      'Аксессуары',
    ],
    'Красота и уход': [
      'Уход за лицом',
      'Уход за телом',
      'Парфюмерия',
      'Макияж',
      'Уход за волосами',
    ],
    'Дом и интерьер': ['Мебель', 'Кухня', 'Освещение', 'Текстиль', 'Декор'],
    'Детские товары': [
      'Игрушки',
      'Детская одежда',
      'Коляски',
      'Подгузники',
      'Товары для школы',
    ],
    'Спорт и отдых': [
      'Фитнес',
      'Велосипеды',
      'Туризм',
      'Спортивная одежда',
      'Тренажёры',
    ],
    'Авто': [
      'Запчасти',
      'Шины и диски',
      'Масла и жидкости',
      'Аксессуары',
      'Электроника для авто',
    ],
  };

  bool get _isEdit => _productId != null;

  @override
  void initState() {
    super.initState();
    _fillFromInitial();
    _load();
  }

  int _categoryId(Map<String, dynamic> item) {
    return int.tryParse((item['category_id'] ?? item['id'] ?? '').toString()) ??
        0;
  }

  String _categoryName(Map<String, dynamic> item) {
    return (item['category_name'] ?? item['name'] ?? item['title'] ?? '')
        .toString();
  }

  String? _resolveGroupByCategoryName(String categoryName) {
    for (final entry in _categoryGroups.entries) {
      if (entry.value.contains(categoryName)) {
        return entry.key;
      }
    }
    return null;
  }

  void _applyGroup(String? group) {
    _selectedGroup = group;

    if (group == null) {
      _filteredCategories = [];
      _selectedCategoryId = null;
      return;
    }

    final allowedNames = _categoryGroups[group] ?? [];

    _filteredCategories = _allCategories
        .where((item) => allowedNames.contains(_categoryName(item)))
        .toList();

    final stillExists = _filteredCategories.any(
      (item) => _categoryId(item) == _selectedCategoryId,
    );

    if (!stillExists) {
      _selectedCategoryId = null;
    }
  }

  void _fillFromInitial() {
    final product = widget.product;
    if (product == null) return;

    _productId = int.tryParse(product['product_id']?.toString() ?? '');
    _selectedCategoryId = int.tryParse(
      product['category_id']?.toString() ?? '',
    );
    _nameController.text = (product['name'] ?? '').toString();
    _descriptionController.text = (product['description'] ?? '').toString();
    _priceController.text = (product['price'] ?? '').toString();
    _quantityController.text = (product['quantity'] ?? '').toString();
    _currencyController.text = (product['currency'] ?? 'BYN').toString();
  }

  Future<void> _load() async {
    final controller = context.read<SellerController>();

    final categories = await controller.getCategories();
    List<Map<String, dynamic>> images = [];

    if (_productId != null) {
      images = await controller.getProductImages(_productId!);
    }

    _allCategories = categories;

    if (_selectedCategoryId != null) {
      final current = _allCategories.where(
        (item) => _categoryId(item) == _selectedCategoryId,
      );
      if (current.isNotEmpty) {
        _selectedGroup = _resolveGroupByCategoryName(
          _categoryName(current.first),
        );
      }
    }

    _applyGroup(_selectedGroup);

    if (!mounted) return;

    setState(() {
      _images = images;
      _isLoading = false;
    });
  }

  Future<void> _saveBasic() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId! <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final controller = context.read<SellerController>();

    if (_productId == null) {
      final createdId = await controller.createProduct(
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        currency: _currencyController.text.trim(),
      );

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
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      currency: _currencyController.text.trim(),
    );

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

  Future<void> _addImage() async {
    if (_productId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сначала сохраните товар')));
      return;
    }

    final imageUrl = _imageUrlController.text.trim();
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 1;

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите ссылку на изображение')),
      );
      return;
    }

    setState(() {
      _isSavingImage = true;
    });

    final ok = await context.read<SellerController>().uploadProductImage(
      productId: _productId!,
      imageUrl: imageUrl,
      sortOrder: sortOrder,
    );

    if (!mounted) return;

    setState(() {
      _isSavingImage = false;
    });

    if (ok) {
      _imageUrlController.clear();
      _sortOrderController.text = '1';
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Изображение добавлено')));
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true
                ? error!
                : 'Не удалось добавить изображение',
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _currencyController.dispose();
    _imageUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Редактировать товар' : 'Новый товар';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SellerProductForm(
                  formKey: _formKey,
                  groupItems: _categoryGroups.keys.toList(),
                  selectedGroup: _selectedGroup,
                  onGroupChanged: (value) {
                    setState(() {
                      _applyGroup(value);
                    });
                  },
                  categories: _filteredCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  priceController: _priceController,
                  quantityController: _quantityController,
                  currencyController: _currencyController,
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
                        : Text(_isEdit ? 'Сохранить товар' : 'Создать товар'),
                  ),
                ),
                if (_productId != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Изображения',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL изображения',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Порядок сортировки',
                      prefixIcon: Icon(Icons.sort_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSavingImage ? null : _addImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: _isSavingImage
                          ? const Text('Добавление...')
                          : const Text('Добавить изображение'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._images.map((image) {
                    final imageId =
                        int.tryParse(image['image_id']?.toString() ?? '') ?? 0;
                    final imageUrl = (image['image_url'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        title: Text(
                          imageUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: () => _deleteImage(imageId),
                          icon: const Icon(Icons.delete_outline),
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
