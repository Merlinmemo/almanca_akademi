import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();

  static final TtsService I = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;

    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _initialized = true;
  }

  Future<void> speakDe(String text, {double rate = 1.0}) async {
    await _ensureInit();
    await _tts.stop();
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate((0.45 * rate).clamp(0.2, 0.8));
    await _tts.speak(text);
  }

  Future<void> speak(String text) async {
    await speakDe(text);
  }

  Future<void> stop() async {
    await _ensureInit();
    await _tts.stop();
  }

  Future<void> clearCache() async {
    // Projede çağrılıyor, derleme için stub bırakıldı.
  }

  Future<void> resetDailyLimit() async {
    // Projede çağrılıyor, derleme için stub bırakıldı.
  }
}