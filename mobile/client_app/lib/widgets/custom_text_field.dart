import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PasswordField({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      validator: widget.validator,
      obscureText: _obscured,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        onPressed: () => setState(() => _obscured = !_obscured),
        color: AppTheme.textHint,
      ),
    );
  }
}
