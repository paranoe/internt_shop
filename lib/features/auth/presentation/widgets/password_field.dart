import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Пароль',
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }
}
