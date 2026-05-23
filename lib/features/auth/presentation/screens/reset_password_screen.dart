import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/core/utils/validators.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/widgets/password_field.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите email';
    if (!text.contains('@')) return 'Некорректный email';
    return null;
  }

  String? _codeValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите код';
    return null;
  }

  String? _confirmValidator(String? value) {
    final base = Validators.password(value);
    if (base != null) return base;
    if ((value ?? '').trim() != _passwordController.text.trim()) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    print('RESET SUBMIT CLICK');
    print('RESET FORM VALID = $valid');

    if (!valid || _isSubmitting) return;

    final authController = context.read<AuthController>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSubmitting = true);

    final ok = await authController.resetPassword(
      email: _emailController.text.trim(),
      code: _codeController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    print('RESET RESULT = $ok');

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (!ok) {
      final error = authController.state.errorMessage;
      if (error != null && error.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Пароль успешно изменён')),
    );
    router.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error &&
            (state.errorMessage?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(height: 8),
                  const AuthHeader(
                    title: 'Новый пароль',
                    subtitle: 'Введите код из письма и задайте новый пароль',
                  ),
                  const SizedBox(height: 24),
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
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _emailValidator,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            validator: _codeValidator,
                            decoration: const InputDecoration(
                              labelText: 'Код',
                              prefixIcon: Icon(Icons.pin_outlined),
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
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Сменить пароль'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
