/*
Speech Recognition States
States for speech to text cubit
*/

import '../../domain/entities/speech_result.dart';

abstract class SpeechRecognitionState {}

// Initial state
class SpeechRecognitionInitial extends SpeechRecognitionState {}

// Loading state - initializing or processing
class SpeechRecognitionLoading extends SpeechRecognitionState {}

// Listening state - microphone is active
class SpeechRecognitionListening extends SpeechRecognitionState {
  final SpeechResult? partialResult;

  SpeechRecognitionListening({this.partialResult});
}

// Success state - got final result
class SpeechRecognitionSuccess extends SpeechRecognitionState {
  final SpeechResult result;

  SpeechRecognitionSuccess(this.result);
}

// Error state
class SpeechRecognitionError extends SpeechRecognitionState {
  final String message;

  SpeechRecognitionError(this.message);
}

// Not available state
class SpeechRecognitionNotAvailable extends SpeechRecognitionState {
  final String message;

  SpeechRecognitionNotAvailable(this.message);
}
