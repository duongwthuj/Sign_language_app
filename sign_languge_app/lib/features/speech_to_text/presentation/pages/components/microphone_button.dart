import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../constants/systems_design.dart';
import '../../cubits/speech_recognition_cubit.dart';
import '../../cubits/speech_recognition_state.dart';

class MicrophoneButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final bool isListening;

  const MicrophoneButton({
    Key? key,
    this.onPressed,
    this.size = 80,
    this.isListening = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeechRecognitionCubit, SpeechRecognitionState>(
      builder: (context, state) {
        final isActive =
            state is SpeechRecognitionLoading ||
            state is SpeechRecognitionListening;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated ripple effect when listening
            if (isActive)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Container(
                    width: size + (value * 30),
                    height: size + (value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(1 - value),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: AppSpacing.md),

            // Main button
            GestureDetector(
              onTap:
                  isActive
                      ? () =>
                          context.read<SpeechRecognitionCubit>().stopListening()
                      : () =>
                          context
                              .read<SpeechRecognitionCubit>()
                              .startListening(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      isActive
                          ? AppGradients.primary
                          : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Microphone icon
                    Icon(
                      isActive ? Icons.mic : Icons.mic_none,
                      size: size * 0.4,
                      color: AppColors.surface,
                    ),

                    // Loading indicator
                    if (state is SpeechRecognitionLoading)
                      SizedBox(
                        width: size * 0.35,
                        height: size * 0.35,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.surface,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Status text with animation
            // Status text with animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Text(
                _getStatusText(state),
                key: ValueKey(_getStatusText(state)),
                style: AppTypography.bodyLarge.copyWith(
                  color: _getStatusColor(state),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(SpeechRecognitionState state) {
    if (state is SpeechRecognitionLoading) return 'Initializing...';
    if (state is SpeechRecognitionListening) return 'Listening...';
    if (state is SpeechRecognitionSuccess) return 'Done';
    if (state is SpeechRecognitionError) {
      return 'Error: ${state.message.split(':').last.trim()}';
    }
    if (state is SpeechRecognitionNotAvailable) return 'Not Available';
    return 'Tap to speak';
  }

  Color _getStatusColor(SpeechRecognitionState state) {
    if (state is SpeechRecognitionLoading ||
        state is SpeechRecognitionListening) {
      return AppColors.primary;
    } else if (state is SpeechRecognitionError) {
      return Colors.red;
    } else if (state is SpeechRecognitionNotAvailable) {
      return Colors.orange;
    }
    return AppColors.textSecondary;
  }
}
