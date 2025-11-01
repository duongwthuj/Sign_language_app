import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const primary = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFF60A5FA);

  // Secondary colors
  static const secondary = Color(0xFF06B6D4);
  static const secondaryDark = Color(0xFF0891B2);

  // Background colors
  static const background = Color(0xFFF0F8FF);
  static const surface = Colors.white;

  // Text colors
  static const textPrimary = Color(0xFF1E3A8A);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);

  // Status colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Glass morphism colors
  static const glassBackground = Color(0x20FFFFFF);
  static const glassBorder = Color(0x4DFFFFFF);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 30.0;
}

class AppTypography {
  static const fontFamily = 'Roboto';

  // Headings
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body text
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const secondary = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3F2FD),
      Color(0xFFBBDEFB),
      Color(0xFF90CAF9),
      Color(0xFF64B5F6),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
}

class AppShadows {
  static const small = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const medium = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const large = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static BoxShadow colored(Color color) => BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      );
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve elastic = Curves.elasticOut;
}

// Common widget styles
class AppStyles {
  static final glassCard = BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1.5,
    ),
  );

  static final glassCardSmall = BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
  );

  static final card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    boxShadow: [AppShadows.medium],
  );

  static final button = BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [AppShadows.small],
  );
}

// Accessibility helpers
class AppAccessibility {
  static const double minTouchTarget = 44.0;
  static const double minContrastRatio = 4.5;

  static Widget semanticButton({
    required String label,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }

  static Widget semanticImage({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      image: true,
      child: child,
    );
  }
}



class AppBorderRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 30.0;
}