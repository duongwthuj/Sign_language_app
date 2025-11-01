import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/speech_result.dart';
import '../../../../constants/systems_design.dart';

class SpeechResultViewPage extends StatefulWidget {
  final SpeechResult result;
  final VoidCallback onRetry;

  const SpeechResultViewPage({
    Key? key,
    required this.result,
    required this.onRetry,
  }) : super(key: key);

  @override
  State<SpeechResultViewPage> createState() => _SpeechResultViewPageState();
}

class _SpeechResultViewPageState extends State<SpeechResultViewPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.result.text);
  }

  @override
  void dispose() {
    _textController.dispose();
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
          'Speech Result',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.md),
              // Recognized text header
              Text(
                'Recognized Text',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              // Editable text field
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 6,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Recognized text will appear here',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              // Metadata section
              _buildMetadataCard(),
              SizedBox(height: AppSpacing.xl),
              // Action buttons
              Text(
                'Actions',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Copy button
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy to Clipboard',
                onTap: _copyToClipboard,
                color: AppColors.primary,
              ),
              SizedBox(height: AppSpacing.md),
              // Share button
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: _shareText,
                color: AppColors.secondary,
              ),
              SizedBox(height: AppSpacing.md),
              // Translate button
              _buildActionButton(
                icon: Icons.translate,
                label: 'Show Sign Language',
                onTap: _showSignLanguageVideo,
                color: Colors.orange,
              ),
              SizedBox(height: AppSpacing.md),
              // Retry button
              _buildActionButton(
                icon: Icons.refresh,
                label: 'Try Again',
                onTap: () {
                  widget.onRetry();
                  Navigator.pop(context);
                },
                color: AppColors.primary,
              ),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recognition Details',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMetadataRow(
            'Confidence',
            '${(widget.result.confidence * 100).toStringAsFixed(1)}%',
            _getConfidenceColor(widget.result.confidence),
          ),
          SizedBox(height: AppSpacing.md),
          _buildMetadataRow(
            'Duration',
            _formatDuration(widget.result.duration),
            AppColors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          _buildMetadataRow(
            'Language',
            widget.result.language.toUpperCase(),
            AppColors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          _buildMetadataRow(
            'Status',
            widget.result.isFinal ? 'Final Result' : 'Partial Result',
            widget.result.isFinal ? Colors.green : Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareText() {
    // For now, just show a message. In production, use share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final millis = (duration.inMilliseconds % 1000) ~/ 100;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s ${millis * 100}ms';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.amber;
    return Colors.red;
  }

  void _showSignLanguageVideo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sign Language Video',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Video demo area
                Expanded(
                  child: Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.videocam,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'Sign Language Demo',
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          _textController.text,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            'Video placeholder\nClick here to play video',
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer with action buttons
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Download feature coming soon'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          label: Text('Close'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
