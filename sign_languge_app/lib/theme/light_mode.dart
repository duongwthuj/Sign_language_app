import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/systems_design.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    // tertiary used in the app for filled surfaces (e.g., textfield fill)
    tertiary: AppColors.surface,
    inversePrimary: AppColors.primaryDark,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  // default visual density and font family could be added here
);
