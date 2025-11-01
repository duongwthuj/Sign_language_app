import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_languge_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:sign_languge_app/features/speech_to_text/presentation/pages/speech_recognition_page.dart';
import 'package:sign_languge_app/constants/systems_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Sign Language App',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () {
              final AuthCubit authCubit = context.read<AuthCubit>();
              authCubit.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xl),
              // Welcome section
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Choose a feature to get started',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.surface.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              // Features title
              Text(
                'Features',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Speech Recognition Card
              _buildFeatureCard(
                context: context,
                icon: Icons.mic,
                title: 'Speech Recognition',
                description: 'Convert speech to text using AI',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpeechRecognitionPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Placeholder for more features
              _buildFeatureCard(
                context: context,
                icon: Icons.translate,
                title: 'Sign Language Dictionary',
                description: 'Learn sign language gestures',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.lg),
              _buildFeatureCard(
                context: context,
                icon: Icons.video_library,
                title: 'Video Tutorials',
                description: 'Watch tutorials on sign language',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            SizedBox(width: AppSpacing.lg),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
