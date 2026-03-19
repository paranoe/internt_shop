import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_state.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/screens/seller_product_edit_screen.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/screens/seller_profile_screen.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/widgets/seller_product_tile.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerController>().loadAll();
    });
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _toStringSafe(dynamic value, {String fallback = '—'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _title() {
    switch (_currentIndex) {
      case 0:
        return 'Товары';
      case 1:
        return 'Заказы';
      case 2:
        return 'Профиль';
      default:
        return 'Seller';
    }
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created') return Colors.blue;
    if (value == 'paid') return Colors.green;
    if (value == 'shipped') return Colors.orange;
    if (value == 'delivered') return Colors.teal;
    if (value == 'cancelled') return Colors.red;

    return Colors.grey;
  }

  String? _nextOrderStatus(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'paid') return 'shipped';
    if (value == 'shipped') return 'delivered';

    return null;
  }

  String _nextOrderStatusTitle(String status) {
    final next = _nextOrderStatus(status);

    if (next == 'shipped') return 'Передать в доставку';
    if (next == 'delivered') return 'Отметить доставленным';

    return '';
  }

  String _statusHint(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'created')
      return 'Ожидает подтверждения оплаты администратором';
    if (value == 'paid') return 'Можно передать заказ в доставку';
    if (value == 'shipped') return 'Можно отметить заказ доставленным';
    if (value == 'delivered') return 'Заказ завершён';

    return '';
  }

  Future<void> _openProfileEdit() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SellerProfileScreen()));

    if (!mounted) return;
    await context.read<SellerController>().loadAll();
  }

  Future<void> _openCreateProduct() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SellerProductEditScreen()));

    if (!mounted) return;
    await context.read<SellerController>().loadProducts();
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerProductEditScreen(product: product),
      ),
    );

    if (!mounted) return;
    await context.read<SellerController>().loadProducts();
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final productId = _toInt(product['product_id']);
    final productName = _toStringSafe(product['name']);

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить товар'),
            content: Text('Удалить "$productName"?'),
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

  Future<void> _showOrderDetails(Map<String, dynamic> order) async {
    final orderId = _toInt(order['order_id']);
    final details = await context.read<SellerController>().getOrderDetails(
      orderId,
    );

    if (!mounted || details == null) return;

    final orderData = Map<String, dynamic>.from(
      details['order'] as Map? ?? const {},
    );
    final items = (details['items'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final status = _toStringSafe(orderData['status'], fallback: '');
    final nextStatus = _nextOrderStatus(status);
    final statusColor = _statusColor(status);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              shrinkWrap: true,
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
                Text(
                  'Заказ #${_toStringSafe(orderData['order_id'])}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusHint(status),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),
                Text('Покупатель: ${_toStringSafe(orderData['buyer_id'])}'),
                Text('ПВЗ: ${_toStringSafe(orderData['pickup_point_id'])}'),
                Text('Сумма: ${_toStringSafe(orderData['total_amount'])}'),
                Text('Дата: ${_toStringSafe(orderData['created_at'])}'),
                const SizedBox(height: 20),
                const Text(
                  'Товары',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        _toStringSafe(item['product_name']),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Количество: ${_toStringSafe(item['quantity'])}\n'
                          'Цена: ${_toStringSafe(item['price_snapshot'])} ${_toStringSafe(item['currency'], fallback: '')}',
                        ),
                      ),
                      trailing: Text(
                        _toStringSafe(item['line_total']),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                if (nextStatus != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop(nextStatus);
                      },
                      child: Text(_nextOrderStatusTitle(status)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    final ok = await context.read<SellerController>().updateOrderStatus(
      orderId: orderId,
      status: result,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Статус заказа обновлён: $result')),
      );
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true ? error! : 'Не удалось обновить статус',
          ),
        ),
      );
    }
  }

  Widget _buildProductsTab(SellerState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<SellerController>().loadProducts(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _openCreateProduct,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Добавить товар'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.products.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(Icons.storefront_outlined, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'У продавца пока нет товаров',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          else
            ...state.products.map(
              (product) => SellerProductTile(
                product: product,
                onEdit: () => _editProduct(product),
                onDelete: () => _deleteProduct(product),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(SellerState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<SellerController>().loadOrders(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'У продавца пока нет заказов',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          else
            ...state.orders.map((order) {
              final orderId = _toInt(order['order_id']);
              final amount = _toStringSafe(order['total_amount']);
              final status = _toStringSafe(order['status']);
              final createdAt = _toStringSafe(order['created_at']);
              final sellerItemsCount = _toStringSafe(
                order['seller_items_count'],
              );
              final statusColor = _statusColor(status);
              final nextStatus = _nextOrderStatus(status);
              final hint = _statusHint(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заказ #$orderId',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (hint.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        hint,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('Сумма: $amount'),
                    Text('Товаров продавца: $sellerItemsCount'),
                    Text('Дата: $createdAt'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showOrderDetails(order),
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Подробнее'),
                          ),
                        ),
                        if (nextStatus != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final ok = await context
                                    .read<SellerController>()
                                    .updateOrderStatus(
                                      orderId: orderId,
                                      status: nextStatus,
                                    );

                                if (!mounted) return;

                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Статус обновлён: $nextStatus',
                                      ),
                                    ),
                                  );
                                } else {
                                  final error = context
                                      .read<SellerController>()
                                      .state
                                      .errorMessage;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error?.isNotEmpty == true
                                            ? error!
                                            : 'Не удалось обновить статус',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(_nextOrderStatusTitle(status)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProfileTab(SellerState state) {
    final profile = state.profile;
    final authState = context.read<AuthController>().state;
    final role = _toStringSafe(authState.user?.role, fallback: 'seller');

    final shopName = _toStringSafe(
      profile?['shop_name'],
      fallback: 'Магазин не заполнен',
    );
    final description = _toStringSafe(
      profile?['description'],
      fallback: 'Добавьте описание магазина',
    );
    final inn = _toStringSafe(profile?['inn']);
    final unp = _toStringSafe(profile?['unp']);
    final sellerId = _toStringSafe(profile?['seller_id']);
    final exists = profile?['exists'] == true;

    return RefreshIndicator(
      onRefresh: () => context.read<SellerController>().loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: const Text(
              'Кабинет продавца',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Информация о продавце',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Роль', value: role),
                _InfoRow(label: 'Seller ID', value: sellerId),
                _InfoRow(
                  label: 'Профиль магазина',
                  value: exists ? 'Создан' : 'Не заполнен',
                ),
                const SizedBox(height: 10),
                Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'ИНН', value: inn),
                _InfoRow(label: 'УНП', value: unp),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openProfileEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать профиль'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthController>().logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: Text(_title()), centerTitle: true),
      body: BlocBuilder<SellerController, SellerState>(
        builder: (context, state) {
          final isLoading =
              state.status == SellerStatus.loading &&
              state.products.isEmpty &&
              state.orders.isEmpty &&
              state.profile == null;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SellerStatus.error &&
              state.products.isEmpty &&
              state.orders.isEmpty &&
              state.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить кабинет продавца',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_currentIndex == 0) {
            return _buildProductsTab(state);
          }
          if (_currentIndex == 1) {
            return _buildOrdersTab(state);
          }
          return _buildProfileTab(state);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Товары',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Заказы',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
