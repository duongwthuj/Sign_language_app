import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/systems_design.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    tertiary: AppColors.surface,
    inversePrimary: AppColors.primary,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  ),
  scaffoldBackgroundColor: AppColors.primaryDark,
);
