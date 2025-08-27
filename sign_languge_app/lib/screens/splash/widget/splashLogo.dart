import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/design_system.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
        ),
        child: Icon(
          Icons.sign_language_outlined,
          size: 80,
          color: AppColors.background,
        )
        );
      },
    );
  }
}
