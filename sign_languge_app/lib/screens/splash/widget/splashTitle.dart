import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/design_system.dart';

class SplashTitle extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  const SplashTitle({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Text(
              'Giao tiếp ngôn ngữ ký hiệu',
              style: TextStyle(
                fontSize: AppTypography.h1.fontSize! - 5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FadeTransition(
          opacity: fadeAnimation,
          child: Text(
            'Kết nối thế giới qua cử chỉ',
            style: TextStyle(
              fontSize: AppTypography.bodySmall.fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
