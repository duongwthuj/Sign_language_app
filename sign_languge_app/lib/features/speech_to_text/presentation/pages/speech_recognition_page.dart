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
      body: CustomScrollView(
        slivers: [
          // Modern AppBar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.md,
                    top: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghi âm lời nói',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Chuyển đổi thành ngôn ngữ ký hiệu',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.surface.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Main Content
          SliverToBoxAdapter(
            child: BlocListener<SpeechRecognitionCubit, SpeechRecognitionState>(
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
              child:
                  BlocBuilder<SpeechRecognitionCubit, SpeechRecognitionState>(
                    builder: (context, state) {
                      return Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: AppSpacing.xl),
                            // State widget
                            _buildStateWidget(state),
                            SizedBox(height: AppSpacing.xxl),
                            // Microphone button section
                            _buildMicrophoneSection(context, state),
                            SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
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
      return SizedBox.shrink(); // Không hiển thị ở đây - sẽ hiển thị ở dưới
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
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Lỗi',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 24),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Không có sẵn',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

  // Build microphone button section with professional design
  Widget _buildMicrophoneSection(
    BuildContext context,
    SpeechRecognitionState state,
  ) {
    final isListening = state is SpeechRecognitionListening;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large animated microphone button
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
              gradient:
                  isListening
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      )
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
              boxShadow: [
                BoxShadow(
                  color:
                      isListening
                          ? Colors.red.withOpacity(0.4)
                          : AppColors.primary.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.stop_circle : Icons.mic,
              size: 70,
              color: AppColors.surface,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxl),

        // Status text
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(isListening),
            children: [
              Text(
                isListening ? 'Đang ghi âm...' : 'Nhấn để bắt đầu',
                style: AppTypography.h3.copyWith(
                  color: isListening ? Colors.red : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                isListening ? 'Nói rõ và tự nhiên' : 'Ghi âm lời nói của bạn',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        if (isListening) ...[
          SizedBox(height: AppSpacing.xxl),
          // Listening indicator
          ListeningIndicator(isListening: true, height: 50),
          SizedBox(height: AppSpacing.xxl),
          // Cancel button
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              onPressed: () => _speechCubit.cancelListening(),
              icon: Icon(Icons.close, size: 20),
              label: Text('Hủy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
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
