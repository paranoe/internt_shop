import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _innController = TextEditingController();
  final _unpController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await context.read<SellerController>().getProfile();

    if (!mounted) return;

    if (profile != null) {
      _shopNameController.text = (profile['shop_name'] ?? '').toString();
      _descriptionController.text = (profile['description'] ?? '').toString();
      _innController.text = (profile['inn'] ?? '').toString();
      _unpController.text = (profile['unp'] ?? '').toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final ok = await context.read<SellerController>().updateProfile(
      shopName: _shopNameController.text.trim(),
      description: _descriptionController.text.trim(),
      inn: _innController.text.trim(),
      unp: _unpController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль продавца сохранён')),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = context.read<SellerController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true ? error! : 'Не удалось сохранить профиль',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _innController.dispose();
    _unpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кабинет продавца')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _shopNameController,
                        decoration: const InputDecoration(
                          labelText: 'Название магазина',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Введите название магазина';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _innController,
                        decoration: const InputDecoration(
                          labelText: 'ИНН',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _unpController,
                        decoration: const InputDecoration(
                          labelText: 'УНП',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
