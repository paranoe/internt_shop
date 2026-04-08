import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminSellersScreen extends StatefulWidget {
  const AdminSellersScreen({super.key});

  @override
  State<AdminSellersScreen> createState() => _AdminSellersScreenState();
}

class _AdminSellersScreenState extends State<AdminSellersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadSellers();
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
      context.read<AdminController>().loadSellers(query: value);
    });
  }

  Future<void> _showSellerDialog({Map<String, dynamic>? seller}) async {
    final isEdit = seller != null;
    final formKey = GlobalKey<FormState>();

    final shopNameController = TextEditingController(
      text: seller?['shop_name']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: seller?['description']?.toString() ?? '',
    );
    final innController = TextEditingController(
      text: seller?['inn']?.toString() ?? '',
    );
    final unpController = TextEditingController(
      text: seller?['unp']?.toString() ?? '',
    );
    final userIdController = TextEditingController(
      text: seller?['user_id']?.toString() ?? '',
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
                                ? 'Редактировать продавца'
                                : 'Создать продавца',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: shopNameController,
                          label: 'Название магазина',
                          icon: Icons.storefront_outlined,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Описание',
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(Icons.description_outlined),
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
                          controller: innController,
                          label: 'ИНН',
                          icon: Icons.badge_outlined,
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: unpController,
                          label: 'УНП',
                          icon: Icons.confirmation_number_outlined,
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: userIdController,
                          label: 'user_id',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final userId =
                                  int.tryParse(userIdController.text.trim()) ??
                                  0;

                              bool ok;
                              if (isEdit) {
                                ok = await context
                                    .read<AdminController>()
                                    .updateSeller(
                                      sellerId: int.parse(
                                        seller['seller_id'].toString(),
                                      ),
                                      shopName: shopNameController.text.trim(),
                                      description: descriptionController.text
                                          .trim(),
                                      inn: innController.text.trim(),
                                      unp: unpController.text.trim(),
                                      userId: userId,
                                    );
                              } else {
                                ok = await context
                                    .read<AdminController>()
                                    .createSeller(
                                      shopName: shopNameController.text.trim(),
                                      description: descriptionController.text
                                          .trim(),
                                      inn: innController.text.trim(),
                                      unp: unpController.text.trim(),
                                      userId: userId,
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
        ) ??
        false;

    if (!mounted) return;

    if (done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Продавец обновлён' : 'Продавец создан'),
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

  Future<void> _confirmDelete(int sellerId, String shopName) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить продавца'),
            content: Text('Удалить "$shopName"?'),
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

    final ok = await context.read<AdminController>().deleteSeller(sellerId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Продавец удалён' : 'Не удалось удалить продавца'),
      ),
    );
  }

  static Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: required
          ? (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Заполните поле';
              }
              return null;
            }
          : null,
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

  Future<void> _reload() async {
    await context.read<AdminController>().loadSellers(
      query: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Продавцы'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading && state.sellers.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.sellers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить продавцов',
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
                    hintText: 'Поиск продавца',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<AdminController>().loadSellers();
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
                        onPressed: () => _showSellerDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить продавца'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.sellers.isEmpty)
                  const _AdminSellersEmptyBlock(
                    icon: Icons.storefront_outlined,
                    text: 'Продавцов пока нет',
                  )
                else
                  ...state.sellers.map((seller) {
                    final sellerId =
                        int.tryParse(seller['seller_id'].toString()) ?? 0;
                    final shopName =
                        seller['shop_name']?.toString() ?? 'Магазин';
                    final description = seller['description']?.toString() ?? '';
                    final inn = seller['inn']?.toString() ?? '—';
                    final unp = seller['unp']?.toString() ?? '—';
                    final userId = seller['user_id']?.toString() ?? '—';

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
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.storefront_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shopName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (description.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text('seller_id: $sellerId'),
                                Text('user_id: $userId'),
                                Text('ИНН: $inn'),
                                Text('УНП: $unp'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showSellerDialog(seller: seller),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: sellerId == 0
                                    ? null
                                    : () => _confirmDelete(sellerId, shopName),
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

class _AdminSellersEmptyBlock extends StatelessWidget {
  const _AdminSellersEmptyBlock({required this.icon, required this.text});

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
