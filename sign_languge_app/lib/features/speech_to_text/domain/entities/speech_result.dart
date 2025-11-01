/*
Speech Recognition Result Entity
Represents the result of speech to text conversion
*/

class SpeechResult {
  final String text;
  final bool isFinal;
  final double confidence; // 0.0 - 1.0
  final Duration duration;
  final String language;

  const SpeechResult({
    required this.text,
    required this.isFinal,
    required this.confidence,
    required this.duration,
    required this.language,
  });

  // Copy with method
  SpeechResult copyWith({
    String? text,
    bool? isFinal,
    double? confidence,
    Duration? duration,
    String? language,
  }) {
    return SpeechResult(
      text: text ?? this.text,
      isFinal: isFinal ?? this.isFinal,
      confidence: confidence ?? this.confidence,
      duration: duration ?? this.duration,
      language: language ?? this.language,
    );
  }

  @override
  String toString() =>
      'SpeechResult(text: $text, isFinal: $isFinal, confidence: $confidence, duration: $duration, language: $language)';
}
