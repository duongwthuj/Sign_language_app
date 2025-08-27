import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/design_system.dart';
import 'package:sign_languge_app/screens/splash/widget/loadingProcess.dart';
import 'package:sign_languge_app/screens/splash/widget/splashLogo.dart';
import 'package:sign_languge_app/screens/splash/widget/splashTitle.dart';
import 'package:sign_languge_app/utlis/animation_manager.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<splashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  late final Animation<double> _logoAnimation;

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
  }

  void _startSplashAnimation() {
    _logoController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SplashLogo(animation: _logoAnimation),

            const SizedBox(height: AppSpacing.xl),

            SplashTitle(),

            const SizedBox(height: AppSpacing.xl),

            LoadingProcess(),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
