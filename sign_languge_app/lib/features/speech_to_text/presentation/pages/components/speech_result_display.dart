import 'package:flutter/material.dart';
import '../../../domain/entities/speech_result.dart';
import '../../../../../constants/systems_design.dart';

class SpeechResultDisplay extends StatelessWidget {
  final SpeechResult? result;
  final bool isPartial;
  final double borderRadius;

  const SpeechResultDisplay({
    Key? key,
    this.result,
    this.isPartial = false,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'No speech recognized yet',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color:
            isPartial ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              isPartial
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
          width: isPartial ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPartial ? 'Partial Result' : 'Final Result',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (result!.isFinal)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Final',
                    style: AppTypography.caption.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // Recognized text
          Text(
            result!.text.isNotEmpty ? result!.text : '(empty)',
            style: AppTypography.bodyLarge.copyWith(
              color:
                  result!.text.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          // Metadata
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetadataRow(
                  'Confidence',
                  '${(result!.confidence * 100).toStringAsFixed(1)}%',
                  _getConfidenceColor(result!.confidence),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildMetadataRow(
                  'Duration',
                  _formatDuration(result!.duration),
                  AppColors.primary,
                ),
                SizedBox(height: AppSpacing.sm),
                _buildMetadataRow(
                  'Language',
                  result!.language.toUpperCase(),
                  AppColors.primary,
                ),
              ],
            ),
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
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = (duration.inMilliseconds % 1000) ~/ 100;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s ${milliseconds * 100}ms';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.amber;
    return Colors.red;
  }
}
