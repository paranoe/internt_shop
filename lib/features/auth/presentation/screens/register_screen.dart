import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/guards.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/utils/validators.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/widgets/password_field.dart';

enum RegisterRole { buyer, seller }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopNameController = TextEditingController();

  RegisterRole _selectedRole = RegisterRole.buyer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? value) {
    final base = Validators.password(value);
    if (base != null) return base;

    if (value != _passwordController.text.trim()) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  String? _shopNameValidator(String? value) {
    if (_selectedRole == RegisterRole.seller) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Введите название магазина';
    }
    return null;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final role = _selectedRole == RegisterRole.seller ? 'seller' : 'buyer';

    final ok = await context.read<AuthController>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: role,
      shopName: _selectedRole == RegisterRole.seller
          ? _shopNameController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (ok) {
      final userRole = context.read<AuthController>().state.user?.role;
      context.go(RouteGuards.homeByRole(userRole));
    }
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthController, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(RouteGuards.homeByRole(state.user?.role));
        }

        if (state.status == AuthStatus.error &&
            (state.errorMessage?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF5F3FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(height: 8),
                    const AuthHeader(
                      title: 'Создать аккаунт',
                      subtitle:
                          'Выберите роль и зарегистрируйтесь в приложении',
                    ),
                    const SizedBox(height: 24),
                    _roleCard(
                      title: 'Покупатель',
                      subtitle: 'Покупки, корзина, заказы, отзывы',
                      icon: Icons.shopping_bag_outlined,
                      selected: _selectedRole == RegisterRole.buyer,
                      onTap: () {
                        setState(() {
                          _selectedRole = RegisterRole.buyer;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _roleCard(
                      title: 'Продавец',
                      subtitle: 'Товары, управление магазином, заказы',
                      icon: Icons.storefront_outlined,
                      selected: _selectedRole == RegisterRole.seller,
                      onTap: () {
                        setState(() {
                          _selectedRole = RegisterRole.seller;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_selectedRole == RegisterRole.seller) ...[
                              TextFormField(
                                controller: _shopNameController,
                                validator: _shopNameValidator,
                                decoration: const InputDecoration(
                                  labelText: 'Название магазина',
                                  prefixIcon: Icon(
                                    Icons.store_mall_directory_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              controller: _passwordController,
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              controller: _confirmPasswordController,
                              labelText: 'Подтвердите пароль',
                              validator: _confirmValidator,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _selectedRole == RegisterRole.seller
                                          ? 'Создать магазин'
                                          : 'Зарегистрироваться',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text('Уже есть аккаунт? Войти'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
