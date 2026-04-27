import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_cities_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_parameters_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_pickup_points_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_reviews_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_sellers_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_subcategories_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;
    await context.read<AdminController>().loadDashboard();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Панель администратора'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: () {
              context.read<AuthController>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading && state.stats == null;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.stats == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ??
                      'Не удалось загрузить панель администратора',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final stats = state.stats ?? const <String, dynamic>{};

          final ordersCreated = _toInt(stats['orders_created']);
          final ordersTotal = _toInt(stats['orders_total']);
          final productsTotal = _toInt(stats['products_total']);
          final sellersTotal = _toInt(stats['sellers_total']);
          final usersTotal = _toInt(stats['users_total']);
          final pendingReviews = _toInt(stats['reviews_pending']);

          return RefreshIndicator(
            onRefresh: () => context.read<AdminController>().loadDashboard(),
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
                    'Вы вошли как администратор',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (ordersCreated > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Есть заказы, ожидающие подтверждения оплаты: $ordersCreated',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _openScreen(const AdminOrdersScreen()),
                          child: const Text('Открыть'),
                        ),
                      ],
                    ),
                  ),
                if (pendingReviews > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Есть отзывы на модерации: $pendingReviews',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _openScreen(const AdminReviewsScreen()),
                          child: const Text('Открыть'),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Статистика',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _StatCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Заказы',
                      value: '$ordersTotal',
                      subtitle: 'Всего заказов',
                    ),
                    _StatCard(
                      icon: Icons.payments_outlined,
                      title: 'Оплата',
                      value: '$ordersCreated',
                      subtitle: 'Ждут подтверждения',
                    ),
                    _StatCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Товары',
                      value: '$productsTotal',
                      subtitle: 'В каталоге',
                    ),
                    _StatCard(
                      icon: Icons.storefront_outlined,
                      title: 'Продавцы',
                      value: '$sellersTotal',
                      subtitle: 'Всего продавцов',
                    ),
                    _StatCard(
                      icon: Icons.people_outline,
                      title: 'Пользователи',
                      value: '$usersTotal',
                      subtitle: 'Всего пользователей',
                    ),
                    _StatCard(
                      icon: Icons.rate_review_outlined,
                      title: 'Отзывы',
                      value: '$pendingReviews',
                      subtitle: 'На модерации',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Разделы',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _AdminActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Заказы',
                  subtitle: 'Подтверждение оплаты и смена статусов',
                  onTap: () => _openScreen(const AdminOrdersScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.people_outline,
                  title: 'Пользователи',
                  subtitle: 'Просмотр, редактирование и блокировка',
                  onTap: () => _openScreen(const AdminUsersScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Отзывы',
                  subtitle: 'Модерация отзывов пользователей',
                  onTap: () => _openScreen(const AdminReviewsScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.tune_outlined,
                  title: 'Параметры',
                  subtitle: 'Параметры и привязки к подкатегориям',
                  onTap: () => _openScreen(const AdminParametersScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.category_outlined,
                  title: 'Категории',
                  subtitle: 'Категории каталога',
                  onTap: () => _openScreen(const AdminCategoriesScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Подкатегории',
                  subtitle: 'Подкатегории каталога',
                  onTap: () => _openScreen(const AdminSubcategoriesScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.location_city_outlined,
                  title: 'Города',
                  subtitle: 'Управление списком городов',
                  onTap: () => _openScreen(const AdminCitiesScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'ПВЗ',
                  subtitle: 'Пункты выдачи заказов',
                  onTap: () => _openScreen(const AdminPickupPointsScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Товары',
                  subtitle: 'Просмотр, редактирование и удаление товаров',
                  onTap: () => _openScreen(const AdminProductsScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.storefront_outlined,
                  title: 'Продавцы',
                  subtitle: 'Просмотр и редактирование продавцов',
                  onTap: () => _openScreen(const AdminSellersScreen()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
          ),
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
