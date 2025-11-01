/*
Speech Recognition Repository
Abstract interface for speech to text operations
*/

import '../entities/speech_result.dart';

abstract class SpeechRecognitionRepo {
  // Initialize speech recognizer
  Future<void> initialize();

  // Check if speech recognition is available
  Future<bool> isAvailable();

  // Get list of supported languages
  Future<List<String>> getSupportedLanguages();

  // Start listening
  Future<void> startListening({
    String language = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  });

  // Stop listening
  Future<void> stopListening();

  // Cancel listening
  Future<void> cancelListening();

  // Get current status
  String getStatus();

  // Stream of speech results (partial and final)
  Stream<SpeechResult> get speechResultStream;

  // Stream of listening status
  Stream<bool> get isListeningStream;

  // Dispose resources
  Future<void> dispose();
}
