import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();

  String? _selectedRole;
  bool? _blockedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<AdminController>().loadUsers(
      query: _searchController.text.trim(),
      role: _selectedRole,
      isBlocked: _blockedFilter,
    );
  }

  Future<void> _toggleBlocked(Map<String, dynamic> user) async {
    final userId = int.tryParse(user['user_id'].toString()) ?? 0;
    final isBlocked = user['is_blocked'] == true;

    final ok = await context.read<AdminController>().toggleUserBlocked(
      userId: userId,
      isBlocked: !isBlocked,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (!isBlocked
                    ? 'Пользователь заблокирован'
                    : 'Пользователь разблокирован')
              : 'Не удалось изменить статус',
        ),
      ),
    );
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final userId = int.tryParse(user['user_id'].toString()) ?? 0;
    final email = user['email']?.toString() ?? 'пользователя';

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить пользователя'),
            content: Text('Удалить $email?'),
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

    final ok = await context.read<AdminController>().deleteUser(userId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Пользователь удалён' : 'Не удалось удалить пользователя',
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.deepPurple;
      case 'seller':
        return Colors.teal;
      case 'buyer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _roleRu(String role) {
    switch (role) {
      case 'admin':
        return 'Админ';
      case 'seller':
        return 'Продавец';
      case 'buyer':
        return 'Покупатель';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Пользователи'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить пользователей',
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
                  onSubmitted: (_) => _reload(),
                  decoration: InputDecoration(
                    hintText: 'Поиск по email, телефону, имени',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _reload();
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Роль',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все роли'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'admin',
                      child: Text('Админ'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'seller',
                      child: Text('Продавец'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'buyer',
                      child: Text('Покупатель'),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedRole = value;
                    });
                    await _reload();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool?>(
                  initialValue: _blockedFilter,
                  decoration: InputDecoration(
                    labelText: 'Статус',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<bool?>(value: null, child: Text('Все')),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text('Активные'),
                    ),
                    DropdownMenuItem<bool?>(
                      value: true,
                      child: Text('Заблокированные'),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _blockedFilter = value;
                    });
                    await _reload();
                  },
                ),
                const SizedBox(height: 16),
                if (state.users.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Пользователей пока нет'),
                  )
                else
                  ...state.users.map((user) {
                    final role = user['role']?.toString() ?? '';
                    final isBlocked = user['is_blocked'] == true;
                    final email = user['email']?.toString() ?? '—';
                    final phone = user['phone']?.toString() ?? '—';
                    final firstName = user['first_name']?.toString() ?? '';
                    final lastName = user['last_name']?.toString() ?? '';
                    final fullName = '$lastName $firstName'.trim().isEmpty
                        ? 'Без имени'
                        : '$lastName $firstName'.trim();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: isBlocked
                            ? Border.all(color: Colors.red, width: 1.2)
                            : null,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleColor(
                                    role,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _roleRu(role),
                                  style: TextStyle(
                                    color: _roleColor(role),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Email: $email'),
                          Text('Телефон: $phone'),
                          Text('ID: ${user['user_id']}'),
                          Text(
                            isBlocked
                                ? 'Статус: заблокирован'
                                : 'Статус: активен',
                            style: TextStyle(
                              color: isBlocked ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _toggleBlocked(user),
                                  icon: Icon(
                                    isBlocked ? Icons.lock_open : Icons.block,
                                  ),
                                  label: Text(
                                    isBlocked
                                        ? 'Разблокировать'
                                        : 'Заблокировать',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => _deleteUser(user),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Удалить'),
                                ),
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
