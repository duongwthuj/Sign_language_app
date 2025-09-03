import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/design_system.dart';
import 'package:sign_languge_app/screens/splash/widget/splashLogo.dart';
import 'package:sign_languge_app/screens/splash/widget/splashTitle.dart';
import 'package:sign_languge_app/utlis/animation_manager.dart';
import 'package:sign_languge_app/widget/common/background_bubbles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _progressController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initSplashAnimation();
    _startSplashAnimation();
  }

  void _initSplashAnimation() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimation = AnimationManager.createElasticAnimation(_logoController);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _slideAnimation = AnimationManager.createSlideAnimation(
      _progressController,
    );
    _fadeAnimation = AnimationManager.createFadeAnimation(_progressController);
  }

  void _startSplashAnimation() {
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _progressController.forward();
      }
    });
    _logoController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SplashLogo(animation: _logoAnimation),

                  const SizedBox(height: AppSpacing.xl),

                  SplashTitle(
                    slideAnimation: _slideAnimation,
                    fadeAnimation: _fadeAnimation,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CircularProgressIndicator(),

                  const SizedBox(height: AppSpacing.xl),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall.fontSize,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
