import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_state.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/screens/seller_product_edit_screen.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/widgets/seller_product_tile.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerController>().loadProducts();
    });
  }

  Future<void> _openEdit([Map<String, dynamic>? product]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerProductEditScreen(product: product),
      ),
    );

    if (!mounted) return;
    await context.read<SellerController>().loadProducts();
  }

  Future<void> _delete(Map<String, dynamic> product) async {
    final productId =
        int.tryParse(product['product_id']?.toString() ?? '') ?? 0;
    final name = (product['name'] ?? 'товар').toString();

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

    await context.read<SellerController>().deleteProduct(productId);

    if (!mounted) return;

    final error = context.read<SellerController>().state.errorMessage;
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Товары продавца')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEdit(),
        label: const Text('Добавить товар'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<SellerController, SellerState>(
        builder: (context, state) {
          if (state.status == SellerStatus.loading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SellerStatus.error && state.products.isEmpty) {
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

          if (state.products.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<SellerController>().loadProducts(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.storefront_outlined, size: 64),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'У продавца пока нет товаров',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SellerController>().loadProducts(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: state.products
                  .map(
                    (product) => SellerProductTile(
                      product: product,
                      onEdit: () => _openEdit(product),
                      onDelete: () => _delete(product),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
