import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../constants/systems_design.dart';
import '../cubits/speech_recognition_cubit.dart';
import '../cubits/speech_recognition_state.dart';
import 'components/listening_indicator.dart';
import 'components/microphone_button.dart';
import 'speech_result_view_page.dart';

class SpeechRecognitionPage extends StatefulWidget {
  const SpeechRecognitionPage({Key? key}) : super(key: key);

  @override
  State<SpeechRecognitionPage> createState() => _SpeechRecognitionPageState();
}

class _SpeechRecognitionPageState extends State<SpeechRecognitionPage> {
  late SpeechRecognitionCubit _speechCubit;

  @override
  void initState() {
    super.initState();
    _speechCubit = context.read<SpeechRecognitionCubit>();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    if (mounted) {
      _speechCubit.initialize();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Microphone Permission',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            content: Text(
              'This app needs microphone access to recognize your speech.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: Text(
                  'Open Settings',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _speechCubit.disposeSpeechResources();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Speech Recognition',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SpeechRecognitionCubit, SpeechRecognitionState>(
        listener: (context, state) {
          // Auto-navigate to result view when speech recognition completes
          if (state is SpeechRecognitionSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SpeechResultViewPage(
                      result: state.result,
                      onRetry: () {
                        Navigator.pop(context);
                        _speechCubit.reset();
                      },
                    ),
              ),
            );
          }
        },
        child: BlocBuilder<SpeechRecognitionCubit, SpeechRecognitionState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xl),
                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 50,
                        color: AppColors.surface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    // Title
                    Text(
                      'Speech Recognition',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Subtitle
                    Text(
                      'Tap the microphone button to start speaking',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // State handling
                    _buildStateWidget(state),

                    SizedBox(height: AppSpacing.xxl),

                    // Microphone button
                    MicrophoneButton(
                      size: 80,
                      isListening: state is SpeechRecognitionListening,
                    ),

                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget(SpeechRecognitionState state) {
    if (state is SpeechRecognitionLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state is SpeechRecognitionListening) {
      return ListeningIndicator(isListening: true, height: 60);
    }

    if (state is SpeechRecognitionError) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              state.message,
              style: AppTypography.bodySmall.copyWith(color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (state is SpeechRecognitionNotAvailable) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Not Available',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              state.message,
              style: AppTypography.bodySmall.copyWith(color: Colors.orange),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
