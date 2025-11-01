import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_languge_app/constants/systems_design.dart';
import 'package:sign_languge_app/features/auth/presentation/pages/components/my_button.dart';
import 'package:sign_languge_app/features/auth/presentation/pages/components/my_textfield.dart';
import '../cubits/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? togglePages;

  const LoginScreen({super.key, required this.togglePages});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // auth cubit
  late AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  // login button pressed
  void login() {
    final String email = emailController.text.trim();
    final String pw = pwController.text;

    if (email.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter both email & password."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    authCubit.login(email, pw);
  }

  // forgot password box
  void openForgotPasswordBox() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: EdgeInsets.all(AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Icon(Icons.mail_outline, size: 48, color: AppColors.primary),
                  SizedBox(height: AppSpacing.md),
                  Text("Forgot Password?", style: AppTypography.h3),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    "Enter your email to receive a password reset link",
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Email input
                  MyTextfield(
                    controller: resetEmailController,
                    hintText: "Enter your email",
                    obscureText: false,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: MyButton(
                          onTap: () async {
                            if (resetEmailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Please enter your email",
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            String message = await authCubit.forgotPassword(
                              resetEmailController.text.trim(),
                            );

                            if (mounted) {
                              if (message ==
                                  "Password reset email sent! Check your inbox") {
                                Navigator.pop(context);
                                resetEmailController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          text: "Send Link",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

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
                    Icons.lock_open,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // Title
                Text("Welcome Back", style: AppTypography.h2),

                SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  "Sign in to continue learning",
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppSpacing.xxl),

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

                SizedBox(height: AppSpacing.sm),

                // Forgot password link
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: openForgotPasswordBox,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                // Login button
                MyButton(onTap: login, text: "LOGIN"),

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
                        "Or sign up",
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

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Sign up here",
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
