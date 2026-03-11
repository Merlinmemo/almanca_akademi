import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;

  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<bool> init() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        _isListening = false;
      },
    );

    return _isInitialized;
  }

  Future<bool> startListening({
    required Function(String text) onResult,
  }) async {
    final ok = await init();
    if (!ok) return false;

    _lastWords = '';

    await _speech.listen(
      localeId: 'de_DE',
      listenMode: ListenMode.confirmation,
      partialResults: true,
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
      },
    );

    _isListening = true;
    return true;
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
  }
}