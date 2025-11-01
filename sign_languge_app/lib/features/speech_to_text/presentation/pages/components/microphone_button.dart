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
                duration: Duration(milliseconds: 500),
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
                    // Icon
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
            // Status text
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                _getStatusText(state),
                key: ValueKey<String>(_getStatusKey(state)),
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
    if (state is SpeechRecognitionLoading) {
      return 'Initializing...';
    } else if (state is SpeechRecognitionListening) {
      return 'Listening...';
    } else if (state is SpeechRecognitionSuccess) {
      return 'Done';
    } else if (state is SpeechRecognitionError) {
      return 'Error: ${state.message.split(':').last.trim()}';
    } else if (state is SpeechRecognitionNotAvailable) {
      return 'Not Available';
    }
    return 'Tap to speak';
  }

  String _getStatusKey(SpeechRecognitionState state) {
    if (state is SpeechRecognitionLoading) return 'loading';
    if (state is SpeechRecognitionListening) return 'listening';
    if (state is SpeechRecognitionSuccess) return 'done';
    if (state is SpeechRecognitionError) return 'error';
    if (state is SpeechRecognitionNotAvailable) return 'not_available';
    return 'idle';
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
