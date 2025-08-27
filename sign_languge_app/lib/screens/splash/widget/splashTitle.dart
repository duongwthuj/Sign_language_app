import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/design_system.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Sign Language App', style: AppTypography.h1);
  }
}