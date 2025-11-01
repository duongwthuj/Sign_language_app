import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/systems_design.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 20)
                : null,
        // border when unselected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        // border when selected (focused)
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        // border when error
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
      ),
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.primary,
    );
  }
}
