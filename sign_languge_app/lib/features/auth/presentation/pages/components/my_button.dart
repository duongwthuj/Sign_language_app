import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/systems_design.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final bool isLoading;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;
    final bgColor =
        isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppGradients.primary,
        color: isDisabled ? bgColor : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isDisabled ? [] : [AppShadows.medium],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Center(
            child:
                isLoading
                    ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                        strokeWidth: 2.5,
                      ),
                    )
                    : Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
