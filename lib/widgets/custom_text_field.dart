import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blue[400]) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon, color: Colors.grey[600]),
          onPressed: onSuffixPressed,
        )
            : null,
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}