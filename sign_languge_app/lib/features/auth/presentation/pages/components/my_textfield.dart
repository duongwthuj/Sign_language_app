import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color surface = Theme.of(context).colorScheme.tertiary;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: primary.withOpacity(0.8)),
        // border when unselected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary.withOpacity(0.35), width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        // border when selected
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.6),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: surface,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}
