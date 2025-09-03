import 'package:flutter/material.dart';
import 'package:sign_languge_app/utlis/animation_manager.dart';
import '../../constants/design_system.dart';

class BackgroundBubbles extends StatelessWidget {
  const BackgroundBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top left corner - 2 overlapping bubbles
        Positioned(
          top: -30,
          left: -30,
          child: _buildBubble(120, AppColors.primary, 0.25),
        ),
        Positioned(
          top: -20,
          left: -20,
          child: _buildBubble(100, AppColors.primary, 0.2),
        ),

        // Top right corner - 2 overlapping bubbles
        Positioned(
          top: -25,
          right: -35,
          child: _buildBubble(110, AppColors.primary, 0.22),
        ),
        Positioned(
          top: -15,
          right: -25,
          child: _buildBubble(90, AppColors.primary, 0.18),
        ),

        // Bottom left corner - 2 overlapping bubbles
        Positioned(
          bottom: -35,
          left: -25,
          child: _buildBubble(130, AppColors.primary, 0.28),
        ),
        Positioned(
          bottom: -25,
          left: -15,
          child: _buildBubble(110, AppColors.primary, 0.24),
        ),

        // Bottom right corner - 2 overlapping bubbles
        Positioned(
          bottom: -30,
          right: -30,
          child: _buildBubble(125, AppColors.primary, 0.26),
        ),
        Positioned(
          bottom: -20,
          right: -20,
          child: _buildBubble(105, AppColors.primary, 0.22),
        ),
      ],
    );
  }

  Widget _buildBubble(double size, Color color, double opacity) {
    return TweenAnimationBuilder<double>(
      duration: Duration(
          milliseconds: AnimationManager.bubbleDuration.inMilliseconds +
              (size * 4).toInt()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - value)),
          child: Opacity(
            opacity: opacity * value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.9),
                    color.withValues(alpha: 0.6),
                    color.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
