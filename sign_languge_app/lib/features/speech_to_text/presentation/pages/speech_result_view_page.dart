import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/speech_result.dart';
import '../../../../constants/systems_design.dart';
import '../cubits/speech_result_cubit.dart';
import '../cubits/speech_result_state.dart';
import 'sign_language_video_page.dart';

class SpeechResultViewPage extends StatefulWidget {
  final SpeechResult result;
  final VoidCallback onRetry;

  const SpeechResultViewPage({
    super.key,
    required this.result,
    required this.onRetry,
  });

  @override
  State<SpeechResultViewPage> createState() => _SpeechResultViewPageState();
}

class _SpeechResultViewPageState extends State<SpeechResultViewPage> {
  late TextEditingController _textController;
  late SpeechResultCubit _cubit;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.result.text);
    _cubit = SpeechResultCubit(result: widget.result);
  }

  @override
  void dispose() {
    _textController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SpeechResultCubit, SpeechResultState>(
        listener: (context, state) {
          if (state is TextCopied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is TextShared) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is SignLanguageRequested) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignLanguageVideoPage(text: state.text),
              ),
            );
          } else if (state is SpeechResultError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Gradient AppBar
        SliverAppBar(
          expandedHeight: 140,
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
                  colors: [Colors.green.shade400, Colors.green.shade600],
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
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 28),
                        SizedBox(width: AppSpacing.md),
                        Text(
                          'Ghi âm thành công',
                          style: AppTypography.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kết quả nhận diện của bạn',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.85),
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
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecognizedTextCard(),
                SizedBox(height: AppSpacing.xxl),
                _buildMetadataCard(),
                SizedBox(height: AppSpacing.xxl),
                Text(
                  'Hành động',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildActionButtonsGrid(),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecognizedTextCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.text_fields, color: Colors.green, size: 24),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Văn bản nhận diện',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _textController,
              maxLines: 5,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Nội dung được nhận diện',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết nhận diện',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMetadataRow(
            icon: Icons.precision_manufacturing,
            label: 'Độ chính xác',
            value: '${(widget.result.confidence * 100).toStringAsFixed(1)}%',
            color: _getConfidenceColor(widget.result.confidence),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMetadataRow(
            icon: Icons.schedule,
            label: 'Thời lượng',
            value: _cubit.formatDuration(widget.result.duration),
            color: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMetadataRow(
            icon: Icons.language,
            label: 'Ngôn ngữ',
            value: widget.result.language.toUpperCase(),
            color: Colors.blue,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMetadataRow(
            icon: Icons.info_outline,
            label: 'Trạng thái',
            value: widget.result.isFinal ? 'Kết quả cuối' : 'Kết quả tạm',
            color: widget.result.isFinal ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.copy,
                label: 'Sao chép',
                onTap: () => _cubit.copyToClipboard(_textController.text),
                color: Colors.blue,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                label: 'Chia sẻ',
                onTap: () => _cubit.shareText(_textController.text),
                color: Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.videocam,
                label: 'Ký hiệu',
                onTap: () => _cubit.requestSignLanguage(_textController.text),
                color: Colors.orange,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.refresh,
                label: 'Thử lại',
                onTap: () {
                  widget.onRetry();
                  Navigator.pop(context);
                },
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.amber;
    return Colors.red;
  }
}
