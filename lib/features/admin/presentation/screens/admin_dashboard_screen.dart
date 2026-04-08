import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_cities_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_parameters_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_pickup_points_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_sellers_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

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
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().state.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Панель администратора'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final stats = state.stats ?? const <String, dynamic>{};

          if (state.status == AdminStatus.loading && state.stats == null) {
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

          return RefreshIndicator(
            onRefresh: () => context.read<AdminController>().loadDashboard(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вы вошли как администратор',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_toInt(stats['orders_created']) > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Есть заказы, ожидающие подтверждения оплаты',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Количество: ${_toInt(stats['orders_created'])}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                          ),
                          onPressed: () =>
                              _openScreen(const AdminOrdersScreen()),
                          child: const Text('Открыть заказы'),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Статистика',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: [
                    _StatCard(
                      title: 'Заказы',
                      value: '${_toInt(stats['orders_total'])}',
                      subtitle: 'Всего заказов',
                      icon: Icons.receipt_long_outlined,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Оплата',
                      value: '${_toInt(stats['orders_created'])}',
                      subtitle: 'Ждут подтверждения',
                      icon: Icons.pending_actions_outlined,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Товары',
                      value: '${_toInt(stats['products_total'])}',
                      subtitle: 'В каталоге',
                      icon: Icons.inventory_2_outlined,
                      color: Colors.deepPurple,
                    ),
                    _StatCard(
                      title: 'Продавцы',
                      value: '${_toInt(stats['sellers_total'])}',
                      subtitle: 'Всего продавцов',
                      icon: Icons.storefront_outlined,
                      color: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Разделы', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _AdminActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Заказы',
                  subtitle: 'Подтверждение оплаты и смена статусов',
                  onTap: () => _openScreen(const AdminOrdersScreen()),
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
                  subtitle: 'Категории и подкатегории каталога',
                  onTap: () => _openScreen(const AdminCategoriesScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.location_city_outlined,
                  title: 'Города',
                  subtitle: 'Управление списком городов',
                  onTap: () => _openScreen(const AdminCitiesScreen()),
                ),
                _AdminActionTile(
                  icon: Icons.place_outlined,
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
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
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
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
