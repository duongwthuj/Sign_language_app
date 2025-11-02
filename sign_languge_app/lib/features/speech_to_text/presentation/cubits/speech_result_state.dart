abstract class SpeechResultState {
  const SpeechResultState();
}

class SpeechResultInitial extends SpeechResultState {
  const SpeechResultInitial();
}

class SpeechResultLoading extends SpeechResultState {
  const SpeechResultLoading();
}

class TextCopied extends SpeechResultState {
  final String message;
  const TextCopied(this.message);
}

class TextShared extends SpeechResultState {
  final String message;
  const TextShared(this.message);
}

class SignLanguageRequested extends SpeechResultState {
  final String text;
  const SignLanguageRequested(this.text);
}

class SpeechResultError extends SpeechResultState {
  final String message;
  const SpeechResultError(this.message);
}
