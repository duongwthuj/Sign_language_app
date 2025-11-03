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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        title: Text(
          'Kết quả nhận diện',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecognizedTextCard(),
            SizedBox(height: 24),
            _buildMetadataCard(),
            SizedBox(height: 24),
            _buildActionButtonsGrid(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognizedTextCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Văn bản nhận diện:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 5,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Nội dung được nhận diện',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          _buildMetadataRow(
            label: 'Độ chính xác:',
            value: '${(widget.result.confidence * 100).toStringAsFixed(1)}%',
            color: _getConfidenceColor(widget.result.confidence),
          ),
          SizedBox(height: 12),
          _buildMetadataRow(
            label: 'Thời lượng:',
            value: _cubit.formatDuration(widget.result.duration),
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          _buildMetadataRow(
            label: 'Ngôn ngữ:',
            value: widget.result.language.toUpperCase(),
            color: Colors.blue,
          ),
          SizedBox(height: 12),
          _buildMetadataRow(
            label: 'Trạng thái:',
            value: widget.result.isFinal ? 'Cuối' : 'Tạm',
            color: widget.result.isFinal ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.videocam,
                label: 'Ký hiệu',
                onTap: () => _cubit.requestSignLanguage(_textController.text),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
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
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.arrow_back,
                label: 'Quay lại',
                onTap: () => Navigator.pop(context),
                color: Colors.grey,
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
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
