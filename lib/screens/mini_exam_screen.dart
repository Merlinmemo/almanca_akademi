import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/progress_service.dart';
import '../services/tts_service.dart';

class MiniExamScreen extends StatefulWidget {
  final String moduleCode;
  final int xpReward;

  const MiniExamScreen({
    super.key,
    required this.moduleCode,
    required this.xpReward,
  });

  @override
  State<MiniExamScreen> createState() => _MiniExamScreenState();
}

class _MiniExamScreenState extends State<MiniExamScreen> {
  final _tts = TtsService.I; // singleton
  final _progress = ProgressService();
  final stt.SpeechToText _stt = stt.SpeechToText();

  final List<String> _questions = [
    "Wie heißen Sie?",
    "Wo wohnen Sie?",
    "Was machen Sie beruflich?",
    "Wo arbeiten Sie?",
    "Seit wann lernen Sie Deutsch?",
    "Was möchten Sie trinken?",
    "Wo ist der Bahnhof?",
    "Haben Sie Erfahrung?",
  ];

  late final List<String> _examSet;
  int _index = 0;

  bool _sttReady = false;
  bool _listening = false;
  String _heard = "";
  int _totalScore = 0;

  Timer? _timer;
  int _seconds = 6;

  @override
  void initState() {
    super.initState();
    final list = List<String>.from(_questions)..shuffle();
    _examSet = list.take(5).toList();
    _init();
  }

  Future<void> _init() async {
    _sttReady = await _stt.initialize(
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'done' || s == 'notListening') {
          setState(() => _listening = false);
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _listening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("STT hata: ${e.errorMsg}")),
        );
      },
    );

    // İlk soruyu otomatik okut
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    await _speakCurrent();
  }

  String get _q => _examSet[_index];

  Future<void> _speakCurrent() async {
    // stop = güvenli, ama dispose yok
    await _tts.stop();
    await _tts.speakDe(_q);
  }

  void _startTimer() {
    _seconds = 6;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
        _finishAnswer();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _toggleListen() async {
    if (!_sttReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mikrofon hazır değil. İzinleri kontrol et.")),
      );
      return;
    }

    if (_listening) {
      await _stt.stop();
      _finishAnswer();
      return;
    }

    setState(() {
      _heard = "";
      _listening = true;
    });

    _startTimer();

    await _stt.listen(
      localeId: "de_DE",
      listenMode: stt.ListenMode.confirmation,
      listenFor: const Duration(seconds: 6),
      pauseFor: const Duration(seconds: 2),
      onResult: (r) {
        if (!mounted) return;
        setState(() => _heard = r.recognizedWords);
      },
    );
  }

  int _scoreAnswer(String expected, String heard) {
    final e = expected.toLowerCase().trim();
    final h = heard.toLowerCase().trim();
    if (h.isEmpty) return 0;

    // Basit ama stabil: ilk ana kelimeyi yakalarsa puan ver
    final first = e.split(' ').first;
    if (h.contains(first)) return 20;

    // bazı ekstra tolerans (soru kelimelerinden biri)
    final keys = e.split(' ').where((x) => x.length >= 3).toList();
    for (final k in keys) {
      if (h.contains(k)) return 10;
    }
    return 0;
  }

  Future<void> _finishAnswer() async {
    _timer?.cancel();
    await _stt.stop();

    if (!mounted) return;
    setState(() => _listening = false);

    final gained = _scoreAnswer(_q, _heard);
    _totalScore += gained;

    if (_index >= 4) {
      await _finishExam();
      return;
    }

    setState(() {
      _index++;
      _heard = "";
    });

    await _speakCurrent();
  }

  Future<void> _finishExam() async {
    final passed = _totalScore >= 70;

    if (passed) {
      await _progress.addXp(widget.xpReward + 20);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(passed ? "Başarılı 🎉" : "Tekrar Denemelisin"),
        content: Text("Skor: $_totalScore / 100"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stt.stop();
    // Singleton TTS dispose edilmez
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((_index + 1) / 5).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Prüfung"),
        actions: [
          IconButton(
            onPressed: _speakCurrent,
            icon: const Icon(Icons.volume_up),
            tooltip: "Dinle",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: progress),
                  ),
                ),
                const SizedBox(width: 10),
                Text("${_index + 1}/5"),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _q,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text("Kalan Süre: $_seconds sn"),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _speakCurrent,
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Dinle"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleListen,
                    icon: Icon(_listening ? Icons.stop : Icons.mic),
                    label: Text(_listening ? "Durdur" : "Cevapla"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text("Duyulan: ${_heard.isEmpty ? "—" : _heard}"),
            const Spacer(),
            Text("Skor: $_totalScore / 100", style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}