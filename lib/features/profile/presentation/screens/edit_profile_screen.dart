import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;

  static const _genderItems = <DropdownMenuItem<String?>>[
    DropdownMenuItem<String?>(value: null, child: Text('Не выбран')),
    DropdownMenuItem<String?>(value: 'male', child: Text('Мужской')),
    DropdownMenuItem<String?>(value: 'female', child: Text('Женский')),
  ];

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileController>().state.profile;

    _firstNameController.text = profile?.firstName ?? '';
    _lastNameController.text = profile?.lastName ?? '';
    _patronymicController.text = profile?.patronymic ?? '';
    _phoneController.text = _formatPhone(profile?.phone ?? '');

    final gender = (profile?.gender ?? '').trim().toLowerCase();
    if (gender == 'male' || gender == 'female') {
      _selectedGender = gender;
    } else {
      _selectedGender = null;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _normalizeBelarusPhoneDigits(String value) {
    var digits = _digitsOnly(value);

    if (digits.startsWith('375')) {
      digits = digits.substring(3);
    }

    if (digits.startsWith('80')) {
      digits = digits.substring(2);
    }

    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    return digits;
  }

  String _formatPhone(String input) {
    final digits = _normalizeBelarusPhoneDigits(input);

    if (digits.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('+375');

    if (digits.isNotEmpty) {
      buffer.write(' (');
      buffer.write(digits.substring(0, digits.length.clamp(0, 2)));
    }

    if (digits.length >= 2) {
      buffer.write(') ');
      buffer.write(digits.substring(2, digits.length.clamp(2, 5)));
    }

    if (digits.length >= 5) {
      buffer.write('-');
      buffer.write(digits.substring(5, digits.length.clamp(5, 7)));
    }

    if (digits.length >= 7) {
      buffer.write('-');
      buffer.write(digits.substring(7, digits.length.clamp(7, 9)));
    }

    return buffer.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final normalizedPhone = _normalizeBelarusPhoneDigits(_phoneController.text);

    final ok = await context.read<ProfileController>().updateProfile(
      firstName: _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      patronymic: _patronymicController.text.trim().isEmpty
          ? null
          : _patronymicController.text.trim(),
      phone: normalizedPhone.length == 9 ? _phoneController.text.trim() : null,
      gender: _selectedGender,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
      Navigator.of(context).pop();
    } else {
      final error = context.read<ProfileController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true ? error! : 'Не удалось сохранить',
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF6F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileController, ProfileState>(
      builder: (context, state) {
        final isSaving = state.status == ProfileStatus.saving;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: const Text('Редактировать профиль'),
            centerTitle: true,
            backgroundColor: const Color(0xFFF5F7FB),
            elevation: 0,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            label: 'Имя',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            label: 'Фамилия',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _patronymicController,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            label: 'Отчество',
                            icon: Icons.account_circle_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ByPhoneInputFormatter(),
                          ],
                          decoration: _inputDecoration(
                            label: 'Телефон',
                            icon: Icons.phone_outlined,
                            hint: '+375 (29) 123-45-67',
                          ),
                          validator: (value) {
                            final digits = _normalizeBelarusPhoneDigits(
                              value ?? '',
                            );
                            if (digits.isEmpty) return null;
                            if (digits.length != 9) {
                              return 'Введите номер полностью';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          value: _selectedGender,
                          items: _genderItems,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                          decoration: _inputDecoration(
                            label: 'Пол',
                            icon: Icons.wc_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : _save,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(isSaving ? 'Сохраняем...' : 'Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ByPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('375')) {
      digits = digits.substring(3);
    }

    if (digits.startsWith('80')) {
      digits = digits.substring(2);
    }

    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer('+375');

    if (digits.isNotEmpty) {
      buffer.write(' (');
      buffer.write(digits.substring(0, digits.length.clamp(0, 2)));
    }

    if (digits.length >= 2) {
      buffer.write(') ');
      buffer.write(digits.substring(2, digits.length.clamp(2, 5)));
    }

    if (digits.length >= 5) {
      buffer.write('-');
      buffer.write(digits.substring(5, digits.length.clamp(5, 7)));
    }

    if (digits.length >= 7) {
      buffer.write('-');
      buffer.write(digits.substring(7, digits.length.clamp(7, 9)));
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
