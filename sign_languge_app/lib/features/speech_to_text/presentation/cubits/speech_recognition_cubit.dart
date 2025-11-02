import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/speech_recognition_repo_impl.dart';
import '../../domain/entities/speech_result.dart';
import 'speech_recognition_state.dart';

class SpeechRecognitionCubit extends Cubit<SpeechRecognitionState> {
  final SpeechRecognitionRepoImpl speechRepo;
  String _selectedLanguage = 'vi_VN';
  SpeechResult? _lastResult;
  StreamSubscription<SpeechResult>? _subscription;

  SpeechRecognitionCubit({required this.speechRepo})
      : super(SpeechRecognitionInitial());

  String get selectedLanguage => _selectedLanguage;
  SpeechResult? get lastResult => _lastResult;

  // --- Initialize ---
  Future<void> initialize() async {
    if (isClosed) return;
    emit(SpeechRecognitionLoading());
    try {
      await speechRepo.initialize();
      final available = await speechRepo.isAvailable();
      if (!available) {
        if (!isClosed) {
          emit(SpeechRecognitionNotAvailable(
            'Speech recognition is not available on this device',
          ));
        }
      } else {
        if (!isClosed) emit(SpeechRecognitionInitial());
      }
    } catch (e) {
      if (!isClosed) emit(SpeechRecognitionError('Failed to initialize: $e'));
    }
  }

  // --- Check availability ---
  Future<bool> checkAvailability() async {
    try {
      return await speechRepo.isAvailable();
    } catch (e) {
      if (!isClosed) emit(SpeechRecognitionError('Availability check failed: $e'));
      return false;
    }
  }

  // --- Load supported languages ---
  Future<void> loadLanguages() async {
    try {
      final languages = await speechRepo.getSupportedLanguages();
      print('Supported languages: $languages');
    } catch (e) {
      if (!isClosed) emit(SpeechRecognitionError('Failed to load languages: $e'));
    }
  }

  // --- Set language ---
  void setLanguage(String language) {
    _selectedLanguage = language;
  }

  // --- Start listening ---
  Future<void> startListening() async {
    if (isClosed) return;

    try {
      emit(SpeechRecognitionLoading());

      // Hủy stream cũ nếu có
      await _subscription?.cancel();
      _subscription = null;

      // Lắng nghe stream mới
      _subscription = speechRepo.speechResultStream.listen((result) {
        if (isClosed) return; // Ngăn emit sau khi đóng
        _lastResult = result;

        if (result.isFinal) {
          emit(SpeechRecognitionSuccess(result));
        } else {
          emit(SpeechRecognitionListening(partialResult: result));
        }
      }, onError: (e) {
        if (!isClosed) emit(SpeechRecognitionError('Stream error: $e'));
      });

      await speechRepo.startListening(language: _selectedLanguage);
      if (!isClosed) emit(SpeechRecognitionListening());
    } catch (e) {
      if (!isClosed) {
        emit(SpeechRecognitionError('Failed to start listening: $e'));
      }
    }
  }

  // --- Stop listening ---
  Future<void> stopListening() async {
    try {
      await speechRepo.stopListening();
      if (!isClosed) {
        if (_lastResult != null) {
          emit(SpeechRecognitionSuccess(_lastResult!));
        } else {
          emit(SpeechRecognitionInitial());
        }
      }
    } catch (e) {
      if (!isClosed) emit(SpeechRecognitionError('Failed to stop listening: $e'));
    }
  }

  // --- Cancel listening ---
  Future<void> cancelListening() async {
    try {
      await speechRepo.cancelListening();
      _lastResult = null;
      if (!isClosed) emit(SpeechRecognitionInitial());
    } catch (e) {
      if (!isClosed) emit(SpeechRecognitionError('Failed to cancel listening: $e'));
    }
  }

  // --- Reset state ---
  void reset() {
    _lastResult = null;
    if (!isClosed) emit(SpeechRecognitionInitial());
  }

  // --- Dispose resources ---
  Future<void> disposeSpeechResources() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      await speechRepo.dispose();
      _lastResult = null;
      if (!isClosed) emit(SpeechRecognitionInitial());
    } catch (e) {
      print('Error disposing speech resources: $e');
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await speechRepo.dispose();
    return super.close();
  }
}
