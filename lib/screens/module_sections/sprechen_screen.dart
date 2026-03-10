import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/generated_content_models.dart';
import '../../services/content_engine/sprechen_repository.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

enum SpeakDifficulty { easy, normal, hard }
enum PracticeMode { sentence, word }
enum _SttPhase { idle, starting, listening, stopping }

class SprechenScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;

  const SprechenScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
  });

  @override
  State<SprechenScreen> createState() => _SprechenScreenState();
}

class _SprechenScreenState extends State<SprechenScreen> {
  final ProgressService _p = ProgressService();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late Future<List<SentencePattern>> _qsFuture;
  List<SentencePattern> _qs = const [];

  // ✅ Repeat pool mechanics
  final List<int> _queue = []; // indices to practice
  final Map<int, int> _streak = {}; // index -> consecutive correct
  int _pos = 0; // pointer in queue

  int _correct = 0;

  String _recognized = "";
  bool _listening = false;

  bool _sttReady = false;
  String? _sttError;

  bool _evaluated = false;
  bool _isCorrect = false;
  double _score = 0.0;

  SpeakDifficulty _difficulty = SpeakDifficulty.normal;

  bool _revealHardAnswer = false;
  bool _slowTts = false;

  PracticeMode _mode = PracticeMode.sentence;
  String _wordTarget = "";
  bool _revealHardWord = false;

  List<String> _missing = const [];
  List<String> _extras = const [];
  List<_TokenPair> _closeMismatches = const [];
  List<String> _umlautIssues = const [];

  Timer? _autoStopTimer;
  static const Duration _maxListen = Duration(seconds: 10);

  _SttPhase _phase = _SttPhase.idle;
  bool get _canTapMic => _phase == _SttPhase.idle || _phase == _SttPhase.listening;

  int get _currentIndex => _queue[_pos];
  SentencePattern get _q => _qs[_currentIndex];

  int get _masteredCount =>
      _streak.entries.where((e) => e.value >= 3).map((e) => e.key).toSet().length;

  @override
  void initState() {
    super.initState();
    _initStt();
    _qsFuture = _loadQuestions();
  }

  Future<List<SentencePattern>> _loadQuestions() async {
    // ✅ A) Random 10 on each entry
    final qs = await SprechenRepository.I.loadRandom(moduleCode: widget.moduleCode, level: 4, count: 10);

    if (!mounted) return qs;

    setState(() {
      _qs = qs;
      _queue
        ..clear()
        ..addAll(List<int>.generate(qs.length, (i) => i));
      _streak
        ..clear()
        ..addEntries(List.generate(qs.length, (i) => MapEntry(i, 0)));
      _pos = 0;
      _correct = 0;
    });

    _pickWordTarget();
    return qs;
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    super.dispose();
  }

  Future<void> _initStt() async {
    try {
      final ok = await _speech.initialize(
        onError: (e) => setState(() => _sttError = e.errorMsg),
        onStatus: (_) {},
      );
      if (!mounted) return;
      setState(() {
        _sttReady = ok;
        _sttError = ok ? null : (_sttError ?? "Speech servis başlatılamadı.");
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sttReady = false;
        _sttError = "Speech init hata: $e";
      });
    }
  }

  // -----------------------------
  // TTS
  // -----------------------------
  Future<void> _playSentence({required bool slow}) async {
    final rate = slow ? 0.75 : 1.00;
    await TtsService.I.stop();
    await TtsService.I.speakDe(_q.exampleDe, rate: rate);
  }

  Future<void> _playWord({required bool slow}) async {
    final rate = slow ? 0.75 : 1.00;
    await TtsService.I.stop();
    await TtsService.I.speakDe(_wordTarget, rate: rate);
  }

  // -----------------------------
  // NORMALIZATION / TOKENS
  // -----------------------------
  String _norm(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  List<String> _tokens(String s) {
    final n = _norm(s);
    if (n.isEmpty) return const [];
    return n.split(" ").where((w) => w.isNotEmpty).toList();
  }

  int _min3(int a, int b, int c) => (a < b ? (a < c ? a : c) : (b < c ? b : c));

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;

    List<int> prev = List<int>.generate(n + 1, (j) => j);
    List<int> curr = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      final ca = a.codeUnitAt(i - 1);
      for (int j = 1; j <= n; j++) {
        final cb = b.codeUnitAt(j - 1);
        final cost = (ca == cb) ? 0 : 1;
        final del = prev[j] + 1;
        final ins = curr[j - 1] + 1;
        final sub = prev[j - 1] + cost;
        curr[j] = _min3(del, ins, sub);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }

  double _charSimilarity(String target, String said) {
    final t = _norm(target);
    final u = _norm(said);
    if (t.isEmpty || u.isEmpty) return 0.0;

    final dist = _levenshtein(t, u);
    final maxLen = (t.length > u.length) ? t.length : u.length;
    if (maxLen == 0) return 0.0;

    return (1.0 - (dist / maxLen)).clamp(0.0, 1.0);
  }

  bool _umlautGate(String target, String said) {
    if (_difficulty == SpeakDifficulty.easy) return true;

    final t = target.toLowerCase();
    final s = said.toLowerCase();

    const umlauts = ['ä', 'ö', 'ü'];
    for (final ch in umlauts) {
      if (t.contains(ch) && !s.contains(ch)) return false;
    }

    if (t.contains('ß')) {
      if (_difficulty == SpeakDifficulty.hard) {
        return s.contains('ß');
      } else {
        return s.contains('ß') || s.contains('ss');
      }
    }

    return true;
  }

  bool _tokenSimilar(String a, String b) {
    if (a == b) return true;
    if (a.length < 2 || b.length < 2) return false;

    if ((a.contains(b) || b.contains(a)) && (a.length != b.length)) return false;

    if (!_umlautGate(a, b)) return false;

    if (_difficulty == SpeakDifficulty.hard) {
      final dist = _levenshtein(a, b);
      final tol = (a.length >= 6 && b.length >= 6) ? 1 : 0;
      return dist <= tol;
    }

    final dist = _levenshtein(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    final sim = 1.0 - (dist / maxLen);
    return sim >= 0.90;
  }

  double _tokenRecall(String target, String said) {
    final t = _tokens(target);
    final u = _tokens(said);
    if (t.isEmpty || u.isEmpty) return 0.0;

    int hit = 0;
    for (final w in t) {
      final ok = u.any((x) => _tokenSimilar(w, x));
      if (ok) hit++;
    }
    return (hit / t.length).clamp(0.0, 1.0);
  }

  double _extraPenalty(String target, String said) {
    final t = _tokens(target);
    final u = _tokens(said);
    if (u.isEmpty) return 0.0;

    int extras = 0;
    for (final w in u) {
      final inTarget = t.any((x) => _tokenSimilar(x, w));
      if (!inTarget) extras++;
    }

    final ratioExtra = extras / u.length;
    return (1.0 - ratioExtra).clamp(0.0, 1.0);
  }

  double _orderScore(String target, String said) {
    final t = _tokens(target);
    final u = _tokens(said);
    if (t.isEmpty || u.isEmpty) return 0.0;

    int j = 0;
    int keep = 0;
    for (int i = 0; i < t.length; i++) {
      final tw = t[i];
      while (j < u.length && !_tokenSimilar(tw, u[j])) {
        j++;
      }
      if (j < u.length) {
        keep++;
        j++;
      } else {
        break;
      }
    }
    return (keep / t.length).clamp(0.0, 1.0);
  }

  double _thresholdFor(SpeakDifficulty d) {
    switch (d) {
      case SpeakDifficulty.easy:
        return 0.90;
      case SpeakDifficulty.normal:
        return 0.95;
      case SpeakDifficulty.hard:
        return 0.99;
    }
  }

  double _wordThresholdFor(SpeakDifficulty d) {
    switch (d) {
      case SpeakDifficulty.easy:
        return 0.92;
      case SpeakDifficulty.normal:
        return 0.97;
      case SpeakDifficulty.hard:
        return 0.995;
    }
  }

  void _pickWordTarget() {
    if (_qs.isEmpty) {
      _wordTarget = "";
      return;
    }

    final ws = _tokens(_q.exampleDe);
    if (ws.isEmpty) {
      _wordTarget = "";
      return;
    }

    int score(String w) {
      int s = 0;
      if (w.contains('ä') || w.contains('ö') || w.contains('ü') || w.contains('ß')) s += 5;
      s += w.length;
      if (w.length <= 2) s -= 3;
      return s;
    }

    ws.sort((a, b) => score(b).compareTo(score(a)));
    _wordTarget = ws.first;
  }

  // -----------------------------
  // ANALYZE
  // -----------------------------
  void _analyzeTokens(String target, String said) {
    final t = _tokens(target);
    final u = _tokens(said);

    final missing = <String>[];
    final extras = <String>[];
    final close = <_TokenPair>[];
    final uml = <String>[];

    for (final tw in t) {
      final found = u.any((uw) => _tokenSimilar(tw, uw));
      if (!found) {
        String? best;
        double bestSim = 0.0;

        for (final uw in u) {
          final d = _levenshtein(tw, uw);
          final maxLen = tw.length > uw.length ? tw.length : uw.length;
          final sim = maxLen == 0 ? 0.0 : (1.0 - d / maxLen);
          if (sim > bestSim) {
            bestSim = sim;
            best = uw;
          }
        }

        if (best != null) {
          if (!_umlautGate(tw, best)) {
            uml.add("• '$tw' → '$best' (umlaut/ß hatası)");
          } else if (bestSim >= 0.60 && bestSim < 0.90) {
            close.add(_TokenPair(tw, best, bestSim));
          } else {
            missing.add(tw);
          }
        } else {
          missing.add(tw);
        }
      }
    }

    for (final uw in u) {
      final inTarget = t.any((tw) => _tokenSimilar(tw, uw));
      if (!inTarget) extras.add(uw);
    }

    setState(() {
      _missing = missing;
      _extras = extras;
      _closeMismatches = close;
      _umlautIssues = uml;
    });
  }

  void _analyzeWord(String targetWord, String said) {
    final u = _tokens(said);
    final extras = <String>[];
    final missing = <String>[];
    final close = <_TokenPair>[];
    final uml = <String>[];

    if (u.isEmpty) {
      missing.add(targetWord);
    } else {
      if (u.length > 1) {
        extras.addAll(u.skip(1));
      }

      final saidWord = u.first;
      if (!_umlautGate(targetWord, saidWord)) {
        uml.add("• '$targetWord' → '$saidWord' (umlaut/ß hatası)");
      } else if (!_tokenSimilar(targetWord, saidWord)) {
        final sim = _charSimilarity(targetWord, saidWord);
        if (sim >= 0.60 && sim < 0.95) {
          close.add(_TokenPair(targetWord, saidWord, sim));
        } else {
          missing.add(targetWord);
        }
      }
    }

    setState(() {
      _missing = missing;
      _extras = extras;
      _closeMismatches = close;
      _umlautIssues = uml;
    });
  }

  // -----------------------------
  // Repeat pool update (B)
  // -----------------------------
  void _applyResultToPool({required bool pass}) {
    final idx = _currentIndex;

    if (pass) {
      final next = (_streak[idx] ?? 0) + 1;
      _streak[idx] = next;
    } else {
      _streak[idx] = 0;
      // Yanlış yapılanı tekrar kuyruğuna at
      _queue.add(idx);
    }
  }

  bool _allMastered() {
    if (_qs.isEmpty) return true;
    for (int i = 0; i < _qs.length; i++) {
      if ((_streak[i] ?? 0) < 3) return false;
    }
    return true;
  }

  // -----------------------------
  // STT Start/Stop
  // -----------------------------
  Future<void> _toggleListen() async {
    if (!_canTapMic) return;

    if (_phase == _SttPhase.listening) {
      await _stopAndEvaluate();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (_phase != _SttPhase.idle) return;
    if (mounted) setState(() => _phase = _SttPhase.starting);

    if (!_sttReady) {
      await _initStt();
      if (!_sttReady) {
        if (mounted) setState(() => _phase = _SttPhase.idle);
        return;
      }
    }

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    setState(() {
      _recognized = "";
      _listening = true;
      _sttError = null;

      _evaluated = false;
      _isCorrect = false;
      _score = 0.0;

      _missing = const [];
      _extras = const [];
      _closeMismatches = const [];
      _umlautIssues = const [];

      if (_difficulty == SpeakDifficulty.hard) {
        _revealHardAnswer = false;
        _revealHardWord = false;
      }
    });

    String? localeId;
    try {
      final locales = await _speech.locales();
      final hasDe = locales.any((l) => l.localeId == "de_DE");
      if (hasDe) localeId = "de_DE";
    } catch (_) {
      localeId = null;
    }

    _speech.listen(
      localeId: localeId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      onResult: (res) {
        if (!mounted) return;
        setState(() => _recognized = res.recognizedWords);
      },
    );

    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(_maxListen, () async {
      if (_listening) await _stopAndEvaluate();
    });

    if (mounted) setState(() => _phase = _SttPhase.listening);
  }

  Future<void> _stopAndEvaluate() async {
    if (_phase != _SttPhase.listening) return;
    if (mounted) setState(() => _phase = _SttPhase.stopping);

    _autoStopTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}

    if (!mounted) return;

    final said = _recognized.trim();

    bool pass = false;
    double score = 0.0;

    if (_mode == PracticeMode.word) {
      final target = _wordTarget.trim();
      final u = _tokens(said);

      final saidWord = u.isEmpty ? "" : u.first;
      final onlyOneWord = (u.length == 1);

      _analyzeWord(target, said);

      final sim = _charSimilarity(target, saidWord);
      final okToken = _tokenSimilar(target, saidWord);
      final gateOk = _umlautGate(target, saidWord);

      score = (0.75 * sim) + (0.15 * (onlyOneWord ? 1.0 : 0.0)) + (0.10 * (gateOk ? 1.0 : 0.0));
      pass = okToken && onlyOneWord && score >= _wordThresholdFor(_difficulty);
    } else {
      final charSim = _charSimilarity(_q.exampleDe, said);
      final recall = _tokenRecall(_q.exampleDe, said);
      final penalty = _extraPenalty(_q.exampleDe, said);
      final order = _orderScore(_q.exampleDe, said);

      _analyzeTokens(_q.exampleDe, said);

      score = (0.45 * charSim) + (0.30 * recall) + (0.15 * order) + (0.10 * penalty);

      final hardNeedsOrder = (_difficulty == SpeakDifficulty.hard);
      final orderOk = !hardNeedsOrder || (order >= 0.98);

      final recallOk = (_difficulty == SpeakDifficulty.hard)
          ? (recall >= 1.0)
          : (_difficulty == SpeakDifficulty.normal ? (recall >= 0.95) : (recall >= 0.90));

      pass = orderOk && recallOk && score >= _thresholdFor(_difficulty);
    }

    // ✅ B) update repeat pool
    _applyResultToPool(pass: pass);

    setState(() {
      _listening = false;
      _evaluated = true;
      _score = score.clamp(0.0, 1.0);
      _isCorrect = pass;
      if (pass) _correct++;
    });

    if (mounted) setState(() => _phase = _SttPhase.idle);
  }

  void _retry() {
    _autoStopTimer?.cancel();
    setState(() {
      _recognized = "";
      _evaluated = false;
      _isCorrect = false;
      _score = 0.0;
      _missing = const [];
      _extras = const [];
      _closeMismatches = const [];
      _umlautIssues = const [];
    });
  }

  Future<void> _nextOrFinish() async {
    // Mastery bitti mi?
    if (_allMastered()) {
      await _finish();
      return;
    }

    // Kuyrukta ilerle
    if (_pos < _queue.length - 1) {
      _autoStopTimer?.cancel();
      setState(() {
        _pos++;
        _recognized = "";
        _evaluated = false;
        _isCorrect = false;
        _score = 0.0;
        _missing = const [];
        _extras = const [];
        _closeMismatches = const [];
        _umlautIssues = const [];
        _revealHardAnswer = false;
        _revealHardWord = false;
      });
      _pickWordTarget();
      return;
    }

    // Kuyruk bitti ama herkes 3/3 değilse: (yanlışlar kuyruğa eklenmiş olmalı)
    // Güvenlik için: eğer pos sona geldiyse ve hala mastered değilse, yeniden kontrol:
    if (!_allMastered()) {
      // Eğer gerçekten hiç yeni öğe eklenmemişse, döngüyü başlat:
      setState(() {
        _pos = 0;
        _recognized = "";
        _evaluated = false;
        _isCorrect = false;
        _score = 0.0;
        _missing = const [];
        _extras = const [];
        _closeMismatches = const [];
        _umlautIssues = const [];
        _revealHardAnswer = false;
        _revealHardWord = false;
      });
      _pickWordTarget();
      return;
    }

    await _finish();
  }

  Future<void> _finish() async {
    await _p.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: "speak",
      xpReward: widget.xpReward,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Konuşma tamamlandı 🎤"),
        content: Text("Doğru sayısı: $_correct\nMastery: $_masteredCount / ${_qs.length} (3/3)"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Tamam")),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  String _diffLabel(SpeakDifficulty d) {
    switch (d) {
      case SpeakDifficulty.easy:
        return "Kolay";
      case SpeakDifficulty.normal:
        return "Normal";
      case SpeakDifficulty.hard:
        return "Zor";
    }
  }

  String _modeLabel(PracticeMode m) => m == PracticeMode.sentence ? "Cümle" : "Tek Kelime";


Widget _buildSessionStatsBar() {
  return AppCard(
    child: Row(
      children: [
        Expanded(
          child: _statBox(Icons.tune_rounded, 'Zorluk', _diffLabel(_difficulty)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox(Icons.record_voice_over_rounded, 'Mod', _modeLabel(_mode)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox(Icons.emoji_events_rounded, 'Mastery', '$_masteredCount / ${_qs.length}'),
        ),
      ],
    ),
  );
}

Widget _statBox(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.accent),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.66),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ],
    ),
  );
}


  List<_DiffChip> _buildDiffChips(String target, String spoken) {
    final t = _tokens(target);
    final s = _tokens(spoken);
    final chips = <_DiffChip>[];
    final used = <int>{};

    for (final tw in t) {
      int bestIndex = -1;
      double bestSim = -1;
      for (int i = 0; i < s.length; i++) {
        if (used.contains(i)) continue;
        final sw = s[i];
        final maxLen = tw.length > sw.length ? tw.length : sw.length;
        final sim = maxLen == 0 ? 0.0 : (1.0 - (_levenshtein(tw, sw) / maxLen));
        if (sim > bestSim) {
          bestSim = sim;
          bestIndex = i;
        }
      }

      if (bestIndex == -1) {
        chips.add(_DiffChip(text: tw, kind: _DiffKind.missing));
        continue;
      }

      final sw = s[bestIndex];
      used.add(bestIndex);

      if (_tokenSimilar(tw, sw)) {
        chips.add(_DiffChip(text: sw, kind: _DiffKind.ok));
      } else if (!_umlautGate(tw, sw)) {
        chips.add(_DiffChip(text: sw, kind: _DiffKind.umlaut));
      } else if (bestSim >= 0.60) {
        chips.add(_DiffChip(text: sw, kind: _DiffKind.close));
      } else {
        chips.add(_DiffChip(text: sw, kind: _DiffKind.wrong));
      }
    }

    for (int i = 0; i < s.length; i++) {
      if (!used.contains(i)) {
        chips.add(_DiffChip(text: s[i], kind: _DiffKind.extra));
      }
    }

    return chips;
  }

  Widget _buildRichFeedbackCard() {
    final target = _mode == PracticeMode.word ? _wordTarget : _q.exampleDe;
    final chips = _recognized.trim().isEmpty ? const <_DiffChip>[] : _buildDiffChips(target, _recognized);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hata analizi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            'Yeşil doğru, sarı yakın, kırmızı yanlış, mor umlaut/ß hatası, gri fazla kelime.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.isEmpty
                  ? [
                      Text(
                        'Önce konuş, sonra analiz burada görünecek.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.68),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ]
                  : chips
                      .map((c) => _DiffChipWidget(text: c.text, kind: c.kind))
                      .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _LegendPill(text: 'Doğru', kind: _DiffKind.ok),
              _LegendPill(text: 'Yakın', kind: _DiffKind.close),
              _LegendPill(text: 'Yanlış', kind: _DiffKind.wrong),
              _LegendPill(text: 'Umlaut/ß', kind: _DiffKind.umlaut),
              _LegendPill(text: 'Fazla', kind: _DiffKind.extra),
              _LegendPill(text: 'Eksik', kind: _DiffKind.missing),
            ],
          ),
        ],
      ),
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, sheetSetState) {
            void sync(void Function() fn) {
              if (!mounted) return;
              setState(fn);
              sheetSetState(() {});
            }

            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ayarlar',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Text(
                      'Zorlaştır, kolaylaştır. Ama ana ekranı kabartma tepsisine çevirmeyelim.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Zorluk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SpeakDifficulty.values.map((d) {
                        return ChoiceChip(
                          label: Text(_diffLabel(d)),
                          selected: _difficulty == d,
                          onSelected: (_) {
                            sync(() {
                              _difficulty = d;
                              _evaluated = false;
                              _isCorrect = false;
                              _score = 0.0;
                              _missing = const [];
                              _extras = const [];
                              _closeMismatches = const [];
                              _umlautIssues = const [];
                              _revealHardAnswer = false;
                              _revealHardWord = false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('Mod', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PracticeMode.values.map((m) {
                        return ChoiceChip(
                          label: Text(_modeLabel(m)),
                          selected: _mode == m,
                          onSelected: (_) {
                            sync(() {
                              _mode = m;
                              _evaluated = false;
                              _isCorrect = false;
                              _score = 0.0;
                              _missing = const [];
                              _extras = const [];
                              _closeMismatches = const [];
                              _umlautIssues = const [];
                              _revealHardAnswer = false;
                              _revealHardWord = false;
                              if (m == PracticeMode.word) {
                                _pickWordTarget();
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _slowTts,
                      onChanged: (v) => sync(() => _slowTts = v),
                      title: const Text('Yavaş dinle'),
                      subtitle: const Text('Telaffuz için daha net (0.75x)'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAnalysisSheet() {
    final target = _mode == PracticeMode.word ? _wordTarget : _q.exampleDe;
    final chips = _recognized.trim().isEmpty ? const <_DiffChip>[] : _buildDiffChips(target, _recognized);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Hata analizi',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Text(
                    'Yeşil doğru, sarı yakın, kırmızı yanlış, mor umlaut/ß, gri fazla kelime.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips.isEmpty
                          ? [
                              Text(
                                'Önce konuş. Sonra analiz burada görünecek.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.68),
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ]
                          : chips.map((c) => _DiffChipWidget(text: c.text, kind: c.kind)).toList(),
                    ),
                  ),
                  if (_umlautIssues.isNotEmpty || _missing.isNotEmpty || _extras.isNotEmpty || _closeMismatches.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    if (_umlautIssues.isNotEmpty) ..._umlautIssues.map((e) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(e, style: const TextStyle(fontWeight: FontWeight.w700)),
                        )),
                    if (_missing.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Eksik kelimeler: ${_missing.join(', ')}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    if (_extras.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Fazla kelimeler: ${_extras.join(', ')}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    if (_closeMismatches.isNotEmpty)
                      ..._closeMismatches.map((e) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('${e.target} ↔ ${e.said}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          )),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _LegendPill(text: 'Doğru', kind: _DiffKind.ok),
                      _LegendPill(text: 'Yakın', kind: _DiffKind.close),
                      _LegendPill(text: 'Yanlış', kind: _DiffKind.wrong),
                      _LegendPill(text: 'Umlaut/ß', kind: _DiffKind.umlaut),
                      _LegendPill(text: 'Fazla', kind: _DiffKind.extra),
                      _LegendPill(text: 'Eksik', kind: _DiffKind.missing),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _compactBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgress(double progress) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Cümle konuşma',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              _compactBadge('$_masteredCount/${_qs.length}', AppTheme.accent),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _compactBadge('Doğru $_correct', AppTheme.success),
              _compactBadge('Kalan ${(_qs.length - _masteredCount).clamp(0, _qs.length)}', const Color(0xFFAAB4C8)),
              _compactBadge('Streak ${(_streak[_currentIndex] ?? 0)}/3', const Color(0xFF38BDF8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCoachCard({
    required bool showSentenceAnswer,
    required bool showWordAnswer,
    required int pct,
    required int need,
  }) {
    final targetText = _mode == PracticeMode.word
        ? (showWordAnswer ? _wordTarget : 'Kelimeyi dinle ve söyle')
        : (showSentenceAnswer ? _q.exampleDe : 'Cümleyi dinle ve söyle');
    final statusColor = _evaluated
        ? (_isCorrect ? AppTheme.success : AppTheme.warning)
        : (_listening ? const Color(0xFFF59E0B) : const Color(0xFFAAB4C8));
    final statusText = _evaluated
        ? (_isCorrect ? 'Kabul' : '%$pct / %$need')
        : (_listening ? 'Dinliyor' : 'Hazır');

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Şimdi söyle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              _compactBadge(statusText, statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _evaluated
                ? (_isCorrect ? 'Bu tur kabul edildi. İstersen geç.' : 'Olmadı. Dinle ve tekrar dene.')
                : 'Dinle, sonra mikrofona basıp tekrar et.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(
                  _q.exampleTr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  targetText,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, height: 1.15),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _compactBadge(_diffLabel(_difficulty), AppTheme.accent),
                    _compactBadge(_modeLabel(_mode), const Color(0xFF38BDF8)),
                    if (_difficulty == SpeakDifficulty.hard && _mode == PracticeMode.sentence && !showSentenceAnswer)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _revealHardAnswer = true),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('Göster'),
                      ),
                    if (_difficulty == SpeakDifficulty.hard && _mode == PracticeMode.word && !showWordAnswer)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _revealHardWord = true),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('Göster'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: (_evaluated && _isCorrect) ? null : (_canTapMic ? _toggleListen : null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _listening ? const Color(0xFFF59E0B) : AppTheme.accent,
                      boxShadow: [
                        BoxShadow(
                          color: (_listening ? const Color(0xFFF59E0B) : AppTheme.accent).withOpacity(0.24),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 48,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _listening ? 'Dinliyorum…' : 'Başlamak için mikrofona bas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_mode == PracticeMode.word) {
                            _playWord(slow: _slowTts);
                          } else {
                            _playSentence(slow: _slowTts);
                          }
                        },
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        label: Text(_slowTts ? 'Yavaş' : 'Dinle'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _listening ? null : _retry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Temizle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Söylediğin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                          ),
                          if (_evaluated) _compactBadge('%$pct', _isCorrect ? AppTheme.success : AppTheme.warning),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _recognized.isEmpty ? '—' : _recognized,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      if (_sttError != null) ...[
                        const SizedBox(height: 6),
                        Text('⛔ $_sttError', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _recognized.trim().isEmpty && !_evaluated ? null : _openAnalysisSheet,
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Detay'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openSettingsSheet,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Ayarlar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SentencePattern>>(
      future: _qsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return CoursePage(
            title: widget.title,
            subtitle: 'Telaffuz çalışması',
            leadingIcon: Icons.mic_rounded,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_qs.isEmpty) {
          return CoursePage(
            title: widget.title,
            subtitle: 'Telaffuz çalışması',
            leadingIcon: Icons.mic_rounded,
            body: const Center(child: Text('Konuşma içeriği yok.')),
          );
        }

        final pct = (_score * 100).round();
        final need = ((_mode == PracticeMode.word)
                ? (_wordThresholdFor(_difficulty) * 100)
                : (_thresholdFor(_difficulty) * 100))
            .round();

        final showSentenceAnswer = _difficulty != SpeakDifficulty.hard || _revealHardAnswer;
        final showWordAnswer = _difficulty != SpeakDifficulty.hard || _revealHardWord;
        final progress = (_masteredCount / _qs.length).clamp(0.0, 1.0);

        return CoursePage(
          title: widget.title,
          subtitle: 'Telaffuz ve tekrar',
          leadingIcon: Icons.mic_rounded,
          bottomBar: BottomActionsBar(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _listening ? null : _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tekrar dene'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (!_evaluated || !_isCorrect) ? null : _nextOrFinish,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_allMastered() ? 'Bitir' : 'Sonraki'),
                  ),
                ),
              ],
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactProgress(progress),
                      const SizedBox(height: 10),
                      _buildSessionStatsBar(),
                      const SizedBox(height: 10),
                      _buildCompactCoachCard(
                        showSentenceAnswer: showSentenceAnswer,
                        showWordAnswer: showWordAnswer,
                        pct: pct,
                        need: need,
                      ),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TokenPair {
  final String target;
  final String said;
  final double similarity;
  const _TokenPair(this.target, this.said, this.similarity);
}



enum _DiffKind { ok, close, wrong, umlaut, extra, missing }

class _DiffChip {
  final String text;
  final _DiffKind kind;
  const _DiffChip({required this.text, required this.kind});
}

class _DiffChipWidget extends StatelessWidget {
  final String text;
  final _DiffKind kind;
  const _DiffChipWidget({required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    final style = _diffStyle(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.$2.withOpacity(0.65)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: style.$2,
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final String text;
  final _DiffKind kind;
  const _LegendPill({required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    final style = _diffStyle(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.$2.withOpacity(0.55)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: style.$2,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

(Color, Color) _diffStyle(_DiffKind kind) {
  switch (kind) {
    case _DiffKind.ok:
      return (const Color(0x1A22C55E), const Color(0xFF22C55E));
    case _DiffKind.close:
      return (const Color(0x1AF59E0B), const Color(0xFFF59E0B));
    case _DiffKind.wrong:
      return (const Color(0x1AEF4444), const Color(0xFFEF4444));
    case _DiffKind.umlaut:
      return (const Color(0x1AA855F7), const Color(0xFFA855F7));
    case _DiffKind.extra:
      return (const Color(0x1A94A3B8), const Color(0xFF94A3B8));
    case _DiffKind.missing:
      return (const Color(0x1A64748B), const Color(0xFFCBD5E1));
  }
}
