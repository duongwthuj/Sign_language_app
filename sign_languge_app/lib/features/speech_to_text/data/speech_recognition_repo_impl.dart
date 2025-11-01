/*
Speech Recognition Repository Implementation
Uses speech_to_text package for actual speech recognition
*/

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/entities/speech_result.dart';
import '../domain/repos/speech_recognition_repo.dart';

class SpeechRecognitionRepoImpl implements SpeechRecognitionRepo {
  final SpeechToText _speechToText = SpeechToText();
  final List<SpeechResult> _results = [];
  bool _isListening = false;
  bool _isInitialized = false;
  DateTime? _startTime;

  // Stream controllers for results and listening status
  final _speechResultStreamController =
      StreamController<SpeechResult>.broadcast();
  final _isListeningStreamController = StreamController<bool>.broadcast();

  SpeechRecognitionRepoImpl();

  // Getter for speechResultStream
  @override
  Stream<SpeechResult> get speechResultStream =>
      _speechResultStreamController.stream;

  // Getter for isListeningStream
  @override
  Stream<bool> get isListeningStream => _isListeningStreamController.stream;

  @override
  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        print('Speech recognition already initialized');
        return;
      }

      print('Attempting to initialize speech recognition...');

      bool available = await _speechToText.initialize(
        onError: (error) {
          print('Speech to text error: $error');
        },
        onStatus: (status) {
          print('Speech to text status: $status');
        },
        debugLogging: true, // Enable debug logging
      );

      print('Speech recognition available: $available');

      if (!available) {
        // Try with different locale
        print(
          'Speech recognition not available with default locale, trying en_US...',
        );
        available = await _speechToText.initialize(
          onError: (error) {
            print('Speech to text error (en_US): $error');
          },
          onStatus: (status) {
            print('Speech to text status (en_US): $status');
          },
          debugLogging: true,
        );

        if (!available) {
          throw Exception('Speech recognition not available on this device');
        }
      }

      _isInitialized = true;
      print('Speech recognition initialized successfully');
    } catch (e) {
      _isInitialized = false;
      print('Initialization exception: $e');
      throw Exception('Failed to initialize speech recognition: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // If already initialized, just check the flag
      if (_isInitialized) {
        return true;
      }
      // Otherwise initialize and return result
      await initialize();
      return true;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      return ['en_US']; // Default fallback
    }
  }

  @override
  Future<void> startListening({
    String language = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!_isInitialized) {
        print('Speech recognition not initialized, initializing now...');
        await initialize();
      }

      if (_isListening) {
        print('Already listening, stopping first...');
        await stopListening();
      }

      _results.clear();
      _isListening = true;
      _isListeningStreamController.add(true);
      _startTime = DateTime.now();

      print('Starting listening with language: $language');

      await _speechToText.listen(
        onResult: (result) {
          final duration =
              _startTime != null
                  ? DateTime.now().difference(_startTime!)
                  : Duration.zero;

          final speechResult = SpeechResult(
            text: result.recognizedWords,
            isFinal: result.finalResult,
            confidence: result.confidence,
            duration: duration,
            language: language,
          );
          _results.add(speechResult);

          // Emit result through stream
          _speechResultStreamController.add(speechResult);

          print(
            'Speech result: ${speechResult.text}, isFinal: ${result.finalResult}, duration: $duration',
          );
        },
        localeId: language,
        listenFor: timeout,
      );

      print('Listening started successfully');
    } catch (e) {
      _isListening = false;
      _isListeningStreamController.add(false);
      _startTime = null;
      print('Error in startListening: $e');
      throw Exception('Failed to start listening: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      _isListeningStreamController.add(false);
      _startTime = null;
    } catch (e) {
      throw Exception('Failed to stop listening: $e');
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _isListeningStreamController.add(false);
      _results.clear();
    } catch (e) {
      throw Exception('Failed to cancel listening: $e');
    }
  }

  @override
  String getStatus() {
    if (_isListening) {
      return _speechToText.isListening ? 'listening' : 'processing';
    }
    return 'idle';
  }

  @override
  Future<void> dispose() async {
    try {
      await _speechToText.stop();
      await _speechToText.cancel();
      _results.clear();
      _isListening = false;
      _isInitialized = false;
      _startTime = null;
      await _speechResultStreamController.close();
      await _isListeningStreamController.close();
    } catch (e) {
      print('Error disposing speech recognition: $e');
    }
  }

  // Helper method to get last result
  SpeechResult? getLastResult() {
    return _results.isNotEmpty ? _results.last : null;
  }

  // Helper method to get all results
  List<SpeechResult> getAllResults() {
    return List.unmodifiable(_results);
  }
}
