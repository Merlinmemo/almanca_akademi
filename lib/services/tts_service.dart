import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';

class TtsService {
  TtsService._();
  static final TtsService I = TtsService._();

  final AudioPlayer _player = AudioPlayer();

  static const String _apiKey =
      String.fromEnvironment("GCP_TTS_KEY", defaultValue: "");

  static const String _endpoint =
      "https://texttospeech.googleapis.com/v1/text:synthesize";

  static const int dailyCharacterLimit = 50000;

  DateTime? _lastSpeakAt;
  static const Duration _cooldown = Duration(milliseconds: 500);

  bool _sessionReady = false;

  double _rate = 1.00;

  void setRate(double value) {
    final v = value.clamp(0.60, 1.25);
    _rate = v;
  }

  double get rate => _rate;

  Future<void> _ensureAudioSession() async {
    if (_sessionReady) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _sessionReady = true;
  }

  String _hashTextWithRate(String text, double rate, {bool isSsml = false}) {
    final key =
        "${text.trim()}||rate=${rate.toStringAsFixed(2)}||ssml=$isSsml";
    return sha1.convert(utf8.encode(key)).toString();
  }

  Future<Directory> _getTtsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final ttsDir = Directory("${dir.path}/tts_cache");
    if (!await ttsDir.exists()) {
      await ttsDir.create(recursive: true);
    }
    return ttsDir;
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<bool> _checkDailyLimit(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString("tts_date") ?? "";
    int usedChars = prefs.getInt("tts_used_chars") ?? 0;

    if (savedDate != today) {
      usedChars = 0;
      await prefs.setString("tts_date", today);
      await prefs.setInt("tts_used_chars", 0);
    }

    if (usedChars + text.length > dailyCharacterLimit) return false;

    usedChars += text.length;
    await prefs.setInt("tts_used_chars", usedChars);
    return true;
  }

  String? _buildTeachingSsmlOnlyForExactTokens(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return null;

    final key = raw.toLowerCase();

    const overrides = <String, String>{
      'sch': '<phoneme alphabet="ipa" ph="ʃ">sch</phoneme>',
      'ch': '<phoneme alphabet="ipa" ph="ç">ch</phoneme>',
      'sp': '<phoneme alphabet="ipa" ph="ʃp">sp</phoneme>',
      'st': '<phoneme alphabet="ipa" ph="ʃt">st</phoneme>',
      'ei': '<phoneme alphabet="ipa" ph="aɪ̯">ei</phoneme>',
      'ie': '<phoneme alphabet="ipa" ph="iː">ie</phoneme>',
      'eu': '<phoneme alphabet="ipa" ph="ɔʏ̯">eu</phoneme>',
      'äu': '<phoneme alphabet="ipa" ph="ɔʏ̯">äu</phoneme>',
      'tsch': '<phoneme alphabet="ipa" ph="tʃ">tsch</phoneme>',
      'pf': '<phoneme alphabet="ipa" ph="pf">pf</phoneme>',
      'z': '<phoneme alphabet="ipa" ph="ts">z</phoneme>',
      'a': '<phoneme alphabet="ipa" ph="aː">A</phoneme>',
      'b': '<phoneme alphabet="ipa" ph="beː">B</phoneme>',
      'c': '<phoneme alphabet="ipa" ph="tseː">C</phoneme>',
      'd': '<phoneme alphabet="ipa" ph="deː">D</phoneme>',
      'e': '<phoneme alphabet="ipa" ph="eː">E</phoneme>',
      'f': '<phoneme alphabet="ipa" ph="ɛf">F</phoneme>',
      'g': '<phoneme alphabet="ipa" ph="ɡeː">G</phoneme>',
      'h': '<phoneme alphabet="ipa" ph="haː">H</phoneme>',
      'i': '<phoneme alphabet="ipa" ph="iː">I</phoneme>',
      'j': '<phoneme alphabet="ipa" ph="jɔt">J</phoneme>',
      'k': '<phoneme alphabet="ipa" ph="kaː">K</phoneme>',
      'l': '<phoneme alphabet="ipa" ph="ɛl">L</phoneme>',
      'm': '<phoneme alphabet="ipa" ph="ɛm">M</phoneme>',
      'n': '<phoneme alphabet="ipa" ph="ɛn">N</phoneme>',
      'o': '<phoneme alphabet="ipa" ph="oː">O</phoneme>',
      'p': '<phoneme alphabet="ipa" ph="peː">P</phoneme>',
      'q': '<phoneme alphabet="ipa" ph="kuː">Q</phoneme>',
      'r': '<phoneme alphabet="ipa" ph="ɛʁ">R</phoneme>',
      's': '<phoneme alphabet="ipa" ph="ɛs">S</phoneme>',
      't': '<phoneme alphabet="ipa" ph="teː">T</phoneme>',
      'u': '<phoneme alphabet="ipa" ph="uː">U</phoneme>',
      'v': '<phoneme alphabet="ipa" ph="faʊ">V</phoneme>',
      'w': '<phoneme alphabet="ipa" ph="veː">W</phoneme>',
      'x': '<phoneme alphabet="ipa" ph="ɪks">X</phoneme>',
      'y': '<phoneme alphabet="ipa" ph="ʏpsilɔn">Y</phoneme>',
      'ä': '<phoneme alphabet="ipa" ph="ɛː">Ä</phoneme>',
      'ö': '<phoneme alphabet="ipa" ph="øː">Ö</phoneme>',
      'ü': '<phoneme alphabet="ipa" ph="yː">Ü</phoneme>',
      'ß': '<phoneme alphabet="ipa" ph="ɛsˈt͡sɛt">ß</phoneme>',
    };

    final exact = overrides[key];
    if (exact == null) return null;
    return '<speak>$exact</speak>';
  }

  Future<void> clearCache() async {
    try {
      await stop();
      final dir = await _getTtsDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create(recursive: true);
      debugPrint('TTS cache temizlendi.');
    } catch (e) {
      debugPrint('TTS cache temizleme hatası: $e');
    }
  }

  Future<void> resetDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tts_date');
    await prefs.remove('tts_used_chars');
    debugPrint('TTS günlük limit sayacı sıfırlandı.');
  }

  Future<void> speakDe(String text, {double? rate}) async {
    final t = text.trim();
    if (t.isEmpty) return;

    if (_apiKey.isEmpty) {
      debugPrint(
        'TTS: GCP_TTS_KEY boş. flutter run --dart-define=GCP_TTS_KEY=...',
      );
      return;
    }

    final now = DateTime.now();
    if (_lastSpeakAt != null && now.difference(_lastSpeakAt!) < _cooldown) {
      return;
    }
    _lastSpeakAt = now;

    await _ensureAudioSession();
    await stop();

    final effectiveRate = (rate ?? _rate).clamp(0.60, 1.25);

    final ssml = _buildTeachingSsmlOnlyForExactTokens(t);
    final isSsml = ssml != null;
    final contentForHash = isSsml ? ssml! : t;

    final ttsDir = await _getTtsDirectory();
    final hash = _hashTextWithRate(
      contentForHash,
      effectiveRate,
      isSsml: isSsml,
    );
    final filePath = '${ttsDir.path}/$hash.mp3';
    final file = File(filePath);

    if (!await file.exists()) {
      final allowed = await _checkDailyLimit(t);
      if (!allowed) {
        debugPrint('TTS: Günlük limit doldu.');
        return;
      }

      final uri = Uri.parse('$_endpoint?key=$_apiKey');

      final body = {
        'input': isSsml ? {'ssml': ssml} : {'text': t},
        'voice': {'languageCode': 'de-DE', 'name': 'de-DE-Wavenet-D'},
        'audioConfig': {
          'audioEncoding': 'MP3',
          'speakingRate': double.parse(effectiveRate.toStringAsFixed(2)),
          'pitch': 0.0,
        }
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint('TTS ERROR ${response.statusCode}: ${response.body}');
        return;
      }

      final data = jsonDecode(response.body);
      final audioBase64 = data['audioContent'];
      if (audioBase64 == null) {
        debugPrint('TTS: audioContent null geldi. Response: ${response.body}');
        return;
      }

      final bytes = base64Decode(audioBase64);
      await file.writeAsBytes(bytes, flush: true);
      debugPrint(
        'TTS: cache yazıldı -> $filePath '
        '(rate=${effectiveRate.toStringAsFixed(2)}, ssml=$isSsml)',
      );
    } else {
      debugPrint(
        'TTS: cache hit -> $filePath '
        '(rate=${effectiveRate.toStringAsFixed(2)}, ssml=$isSsml)',
      );
    }

    try {
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      debugPrint('TTS: player error -> $e');
    }
  }

  Future<void> speakDeSlow(String text) async {
    await speakDe(text, rate: 0.75);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
