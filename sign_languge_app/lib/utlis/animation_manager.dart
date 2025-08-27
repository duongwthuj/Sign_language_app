import 'package:flutter/material.dart';

class AnimationManager {
  static const Duration fadeDuration = Duration(milliseconds: 1000);
  static const Duration slideDuration = Duration(milliseconds: 800);
  static const Duration scaleDuration = Duration(milliseconds: 400);
  static const Duration pulseDuration = Duration(milliseconds: 1500);
  static const Duration bubbleDuration = Duration(milliseconds: 1800);

  // Common animation curves
  static const Curve fadeCurve = Curves.easeInOut;
  static const Curve slideCurve = Curves.easeOutCubic;
  static const Curve scaleCurve = Curves.easeOutBack;
  static const Curve pulseCurve = Curves.easeInOut;
  static const Curve elasticCurve = Curves.elasticOut;

  // Fade animation
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: fadeCurve),
    );
  }

  // Slide animation
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 0.3),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: slideCurve),
    );
  }

  // Scale animation
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.9,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: scaleCurve),
    );
  }

  // Pulse animation
  static Animation<double> createPulseAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: controller, curve: pulseCurve),
    );
  }

  // Elastic animation
  static Animation<double> createElasticAnimation(
      AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: elasticCurve),
    );
  }

  // Bubble animation
  static Animation<double> createBubbleAnimation(
    AnimationController controller, {
    double size = 100,
  }) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Staggered animation sequence
  static Future<void> playStaggeredSequence({
    required List<AnimationController> controllers,
    Duration delay = const Duration(milliseconds: 200),
  }) async {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].forward();
      if (i < controllers.length - 1) {
        await Future.delayed(delay);
      }
    }
  }

  // Reverse sequence
  static Future<void> reverseStaggeredSequence({
    required List<AnimationController> controllers,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    for (int i = controllers.length - 1; i >= 0; i--) {
      controllers[i].reverse();
      if (i > 0) {
        await Future.delayed(delay);
      }
    }
  }
}

// Animation mixin for common animation patterns
mixin AnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController fadeController;
  late final AnimationController slideController;
  late final AnimationController scaleController;
  late final AnimationController pulseController;

  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Initialize controllers
    fadeController = AnimationController(
      duration: AnimationManager.fadeDuration,
      vsync: this,
    );

    slideController = AnimationController(
      duration: AnimationManager.slideDuration,
      vsync: this,
    );

    scaleController = AnimationController(
      duration: AnimationManager.scaleDuration,
      vsync: this,
    );

    pulseController = AnimationController(
      duration: AnimationManager.pulseDuration,
      vsync: this,
    );

    // Initialize animations
    fadeAnimation = AnimationManager.createFadeAnimation(fadeController);
    slideAnimation = AnimationManager.createSlideAnimation(slideController);
    scaleAnimation = AnimationManager.createScaleAnimation(scaleController);
    pulseAnimation = AnimationManager.createPulseAnimation(pulseController);
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    scaleController.dispose();
    pulseController.dispose();
    super.dispose();
  }

  // Common animation sequences
  void playEntranceAnimation() {
    AnimationManager.playStaggeredSequence(
      controllers: [fadeController, slideController, scaleController],
    );
  }

  void playExitAnimation() {
    AnimationManager.reverseStaggeredSequence(
      controllers: [scaleController, slideController, fadeController],
    );
  }

  void startPulseAnimation() {
    pulseController.repeat(reverse: true);
  }

  void stopPulseAnimation() {
    pulseController.stop();
    pulseController.reset();
  }
}
