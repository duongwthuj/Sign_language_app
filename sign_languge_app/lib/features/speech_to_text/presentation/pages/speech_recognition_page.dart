import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../constants/systems_design.dart';
import '../cubits/speech_recognition_cubit.dart';
import '../cubits/speech_recognition_state.dart';
import 'components/listening_indicator.dart';
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
              'Ứng dụng cần truy cập microphone để ghi âm lời nói của bạn.',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Ghi âm lời nói',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SpeechRecognitionCubit, SpeechRecognitionState>(
        listener: (context, state) {
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
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStateWidget(state),
                    SizedBox(height: 48),
                    _buildMicrophoneSection(context, state),
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
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      );
    }

    if (state is SpeechRecognitionListening) {
      return SizedBox.shrink();
    }

    if (state is SpeechRecognitionError) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lỗi',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (state is SpeechRecognitionNotAvailable) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Không có sẵn',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildMicrophoneSection(
    BuildContext context,
    SpeechRecognitionState state,
  ) {
    final isListening = state is SpeechRecognitionListening;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone button
        GestureDetector(
          onTap:
              isListening
                  ? () => _speechCubit.stopListening()
                  : () => _speechCubit.startListening(),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? Colors.red : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color:
                      isListening
                          ? Colors.red.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.stop_circle : Icons.mic,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 48),

        // Status text
        Text(
          isListening ? 'Đang ghi âm...' : 'Nhấn để bắt đầu',
          style: TextStyle(
            color: isListening ? Colors.red : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 8),
        Text(
          isListening ? 'Nói rõ và tự nhiên' : 'Ghi âm lời nói của bạn',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),

        if (isListening) ...[
          SizedBox(height: 48),
          ListeningIndicator(isListening: true, height: 50),
          SizedBox(height: 48),
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () => _speechCubit.cancelListening(),
              icon: Icon(Icons.close, size: 20),
              label: Text('Hủy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 2),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
