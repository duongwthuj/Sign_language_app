import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/speech_result.dart';
import 'speech_result_state.dart';

class SpeechResultCubit extends Cubit<SpeechResultState> {
  final SpeechResult result;

  SpeechResultCubit({required this.result}) : super(SpeechResultInitial());

  // Copy to clipboard
  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      emit(TextCopied('Đã sao chép vào clipboard'));
      await Future.delayed(Duration(seconds: 2));
      emit(SpeechResultInitial());
    } catch (e) {
      emit(SpeechResultError('Sao chép thất bại: $e'));
    }
  }

  // Share text
  Future<void> shareText(String text) async {
    try {
      // TODO: Implement actual share functionality
      emit(TextShared('Chia sẻ tính năng sắp ra mắt'));
      await Future.delayed(Duration(seconds: 2));
      emit(SpeechResultInitial());
    } catch (e) {
      emit(SpeechResultError('Chia sẻ thất bại: $e'));
    }
  }

  // Show sign language video
  Future<void> requestSignLanguage(String text) async {
    try {
      emit(SignLanguageRequested(text));
    } catch (e) {
      emit(SpeechResultError('Yêu cầu thất bại: $e'));
    }
  }

  // Format duration
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final millis = (duration.inMilliseconds % 1000) ~/ 100;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s ${millis * 100}ms';
  }

  // Get confidence color
  String getConfidenceLevel(double confidence) {
    if (confidence >= 0.8) return 'Rất cao';
    if (confidence >= 0.6) return 'Trung bình';
    return 'Thấp';
  }
}
