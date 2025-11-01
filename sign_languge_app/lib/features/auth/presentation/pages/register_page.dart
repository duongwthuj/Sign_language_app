import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_languge_app/constants/systems_design.dart';
import 'package:sign_languge_app/features/auth/presentation/pages/components/my_button.dart';
import 'package:sign_languge_app/features/auth/presentation/pages/components/my_textfield.dart';
import '../cubits/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterScreen({super.key, required this.togglePages});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  // register button pressed
  void register() async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isEmpty || name.isEmpty || pw.isEmpty || confirmPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please complete all fields!"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    if (pw != confirmPw) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match!"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    authCubit.register(name, email, pw);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),

                // Logo with shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [AppShadows.medium],
                  ),
                  child: Icon(
                    Icons.person_add_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // Title
                Text("Create Account", style: AppTypography.h2),

                SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  "Join us and start learning",
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppSpacing.xxl),

                // Name input
                MyTextfield(
                  controller: nameController,
                  hintText: "Full name",
                  obscureText: false,
                  prefixIcon: Icons.person_outline,
                ),

                SizedBox(height: AppSpacing.md),

                // Email input
                MyTextfield(
                  controller: emailController,
                  hintText: "Email address",
                  obscureText: false,
                  prefixIcon: Icons.email_outlined,
                ),

                SizedBox(height: AppSpacing.md),

                // Password input
                MyTextfield(
                  controller: pwController,
                  hintText: "Password",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),

                SizedBox(height: AppSpacing.md),

                // Confirm password input
                MyTextfield(
                  controller: confirmPwController,
                  hintText: "Confirm password",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),

                SizedBox(height: AppSpacing.lg),

                // Sign up button
                MyButton(onTap: register, text: "SIGN UP"),

                SizedBox(height: AppSpacing.xl),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.primary.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        "Or sign in",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.primary.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Sign in here",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
