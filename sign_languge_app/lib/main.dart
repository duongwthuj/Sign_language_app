import 'package:flutter/material.dart';
import 'package:sign_languge_app/constants/app_router.dart';
import 'package:sign_languge_app/constants/design_system.dart';
import 'package:sign_languge_app/screens/camera/cameraScreen.dart';
import 'package:sign_languge_app/screens/history/historyScreen.dart';
import 'package:sign_languge_app/screens/home/homeScreen.dart';
import 'package:sign_languge_app/screens/settings/settingScreen.dart';
import 'package:sign_languge_app/screens/splash/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
      ),
      initialRoute: AppRouter.splash,
      routes: {
        AppRouter.splash: (context) => const splashScreen(),
        AppRouter.home: (context) => const HomeScreen(),  
        AppRouter.camera: (context) => const CameraScreen(),
        AppRouter.history: (context) => const HistoryScreen(),
        AppRouter.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
