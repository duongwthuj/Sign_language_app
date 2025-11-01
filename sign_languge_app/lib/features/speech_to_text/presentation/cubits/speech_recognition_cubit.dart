/*
Speech Recognition Cubit
Manages speech to text state and logic
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/speech_recognition_repo_impl.dart';
import '../../domain/entities/speech_result.dart';
import 'speech_recognition_state.dart';

class SpeechRecognitionCubit extends Cubit<SpeechRecognitionState> {
  final SpeechRecognitionRepoImpl speechRepo;
  String _selectedLanguage = 'en_US';
  SpeechResult? _lastResult;

  SpeechRecognitionCubit({required this.speechRepo})
    : super(SpeechRecognitionInitial());

  // Get selected language
  String get selectedLanguage => _selectedLanguage;

  // Get last result
  SpeechResult? get lastResult => _lastResult;

  // Initialize speech recognition
  Future<void> initialize() async {
    emit(SpeechRecognitionLoading());
    try {
      await speechRepo.initialize();
      final available = await speechRepo.isAvailable();
      if (!available) {
        emit(
          SpeechRecognitionNotAvailable(
            'Speech recognition is not available on this device',
          ),
        );
      } else {
        emit(SpeechRecognitionInitial());
      }
    } catch (e) {
      emit(SpeechRecognitionError('Failed to initialize: $e'));
    }
  }

  // Check if speech recognition is available
  Future<bool> checkAvailability() async {
    try {
      return await speechRepo.isAvailable();
    } catch (e) {
      emit(SpeechRecognitionError('Availability check failed: $e'));
      return false;
    }
  }

  // Get supported languages
  Future<void> loadLanguages() async {
    try {
      final languages = await speechRepo.getSupportedLanguages();
      print('Supported languages: $languages');
    } catch (e) {
      emit(SpeechRecognitionError('Failed to load languages: $e'));
    }
  }

  // Set language for speech recognition
  void setLanguage(String language) {
    _selectedLanguage = language;
  }

  // Start listening
  Future<void> startListening() async {
    try {
      emit(SpeechRecognitionLoading());

      // Listen to speech result stream
      speechRepo.speechResultStream.listen((result) {
        _lastResult = result;
        if (result.isFinal) {
          // Emit success state when final result is received
          emit(SpeechRecognitionSuccess(result));
        } else {
          // Emit listening state with partial result
          emit(SpeechRecognitionListening(partialResult: result));
        }
      });

      await speechRepo.startListening(language: _selectedLanguage);
      emit(SpeechRecognitionListening());
    } catch (e) {
      emit(SpeechRecognitionError('Failed to start listening: $e'));
    }
  }

  // Handle partial result
  void onPartialResult(SpeechResult result) {
    emit(SpeechRecognitionListening(partialResult: result));
  }

  // Handle final result
  void onFinalResult(SpeechResult result) {
    _lastResult = result;
    emit(SpeechRecognitionSuccess(result));
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      await speechRepo.stopListening();
      if (_lastResult != null) {
        emit(SpeechRecognitionSuccess(_lastResult!));
      } else {
        emit(SpeechRecognitionInitial());
      }
    } catch (e) {
      emit(SpeechRecognitionError('Failed to stop listening: $e'));
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    try {
      await speechRepo.cancelListening();
      _lastResult = null;
      emit(SpeechRecognitionInitial());
    } catch (e) {
      emit(SpeechRecognitionError('Failed to cancel listening: $e'));
    }
  }

  // Reset state
  void reset() {
    _lastResult = null;
    emit(SpeechRecognitionInitial());
  }

  // Dispose resources
  Future<void> disposeSpeechResources() async {
    try {
      await speechRepo.dispose();
      _lastResult = null;
      emit(SpeechRecognitionInitial());
    } catch (e) {
      print('Error disposing speech resources: $e');
    }
  }
}
