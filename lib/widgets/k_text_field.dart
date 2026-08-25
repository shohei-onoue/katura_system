import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? icon;
  final Widget? suffix;
  final Function(String)? onChanged;
  final bool autofocus;

  const KTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.suffix,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 8.0)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: autofocus,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 12)),
        ),
      ),
    );
  }
}
