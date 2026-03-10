import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../course/course_catalog.dart';
import '../services/progress_service.dart';

// ✅ Coach görevlerini başlatmak için ekranlar
import 'module_sections/sprechen_screen.dart';
import 'module_sections/hoeren_screen.dart';
import 'module_sections/vocab_screen.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final ProgressService _p = ProgressService();

  bool _loading = true;

  int _dailyTarget = 15;
  int _todayDone = 0;
  int _streak = 0;

  List<int> _last7 = const [];
  String? _log;

  bool _taskSpeak = false;
  bool _taskListen = false;
  bool _taskVocab = false;

  String _coachModuleCode = "modul1";

  @override
  void initState() {
    super.initState();
    _load();
  }

  static const _kCoachSpeak = "coachTaskSpeak";
  static const _kCoachListen = "coachTaskListen";
  static const _kCoachVocab = "coachTaskVocab";

  String _kCoachKey(String base, String ymd) => "${base}_$ymd";

  Future<String> _pickCoachModuleCode() async {
    String? lastUnlocked;
    String? lastUnlockedNotCompleted;

    for (final code in CourseCatalog.moduleCodes) {
      final unlocked = await _p.isModuleUnlocked(code);
      if (!unlocked) continue;

      lastUnlocked = code;

      final completed = await _p.isModuleCompleted(code);
      if (!completed) lastUnlockedNotCompleted = code;
    }

    return lastUnlockedNotCompleted ?? lastUnlocked ?? CourseCatalog.firstModuleCode;
  }

  Future<void> _load() async {
    await _p.ensureCourseBoot();

    final daily = await _p.getDailyTargetMinutes();
    final todayDone = await _p.getTodayDoneMinutes();
    final last7 = await _p.getLast7DaysMinutes();
    final log = await _p.getLastStudyLog();
    final streak = await _p.getStreak();

    final coachCode = await _pickCoachModuleCode();

    final prefs = await SharedPreferences.getInstance();
    final ymd = ProgressService.todayYmd();
    final tSpeak = prefs.getBool(_kCoachKey(_kCoachSpeak, ymd)) ?? false;
    final tListen = prefs.getBool(_kCoachKey(_kCoachListen, ymd)) ?? false;
    final tVocab = prefs.getBool(_kCoachKey(_kCoachVocab, ymd)) ?? false;

    if (!mounted) return;
    setState(() {
      _dailyTarget = daily;
      _todayDone = todayDone;
      _last7 = last7;
      _log = log;
      _streak = streak;

      _coachModuleCode = coachCode;

      _taskSpeak = tSpeak;
      _taskListen = tListen;
      _taskVocab = tVocab;

      _loading = false;
    });
  }

  Future<void> _setTarget(int v) async {
    await _p.setDailyTargetMinutes(v);
    await _load();
  }

  Future<void> _addManual(int minutes) async {
    final added = await _p.addManualStudyMinutesToday(minutes);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added <= 0 ? "Bugün manuel ekleme limiti doldu." : "Manuel çalışma eklendi: +$added dk",
        ),
      ),
    );

    await _load();
  }

  String _dayLabel(DateTime d) {
    const names = ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"];
    return names[d.weekday % 7];
  }

  int get _doneTaskCount => (_taskSpeak ? 1 : 0) + (_taskListen ? 1 : 0) + (_taskVocab ? 1 : 0);
  int get _remainingTasks => 3 - _doneTaskCount;

  int get _remainingMinutes {
    final r = _dailyTarget - _todayDone;
    return r < 0 ? 0 : r;
  }

  bool get _allCoachDone => _taskSpeak && _taskListen && _taskVocab;
  bool get _doneByMinutes => _todayDone >= _dailyTarget;

  String get _coachFinishText {
    if (_allCoachDone) return "Koç modu bitti: 3/3 görev tamamlandı ✅";
    if (_doneByMinutes) return "Koç modu bitti: günlük hedef doldu ✅";
    return "Koç modu bitiş: 3 görev veya hedef dakika dolunca";
  }

  Future<void> _setCoachTask(
    String baseKey,
    bool value, {
    required String label,
    required int minutes,
  }) async {
    if (!value) return; // geri alma yok

    final prefs = await SharedPreferences.getInstance();
    final ymd = ProgressService.todayYmd();

    await prefs.setBool(_kCoachKey(baseKey, ymd), true);
    await _p.addStudyMinutesToday(minutes, reason: "Koç: $label");

    if (!mounted) return;
    await _load();
  }

  Future<void> _startSpeak() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SprechenScreen(
          moduleCode: _coachModuleCode,
          title: "Sprechen • Koç",
          xpReward: 10,
        ),
      ),
    );
    await _load();
  }

  Future<void> _startListen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HoerenScreen(
          moduleCode: _coachModuleCode,
          title: "Hören • Koç",
          xpReward: 8,
        ),
      ),
    );
    await _load();
  }

  Future<void> _startVocab() async {
    final m = CourseCatalog.modules.firstWhere(
      (x) => x.code == _coachModuleCode,
      orElse: () => CourseCatalog.modules.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabScreen(
          moduleCode: _coachModuleCode,
          title: "Wortschatz • Koç",
          xpReward: 8,
          words: m.words,
        ),
      ),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Çalışma Planı")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ratio = _dailyTarget == 0 ? 0.0 : (_todayDone / _dailyTarget);
    final progress = ratio.clamp(0.0, 1.0);

    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    final maxV = (_last7.isEmpty ? 1 : _last7.reduce((a, b) => a > b ? a : b)).clamp(1, 9999);

    final doneBadge = (_allCoachDone || _doneByMinutes);

    return Scaffold(
      appBar: AppBar(title: const Text("Çalışma Planı")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Koç Modu",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      if (doneBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.green.withOpacity(0.18),
                            border: Border.all(color: Colors.green.withOpacity(0.40)),
                          ),
                          child: const Text("Bugün tamam ✅", style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Streak: $_streak gün", style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text("Modül: $_coachModuleCode",
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),

                  // ✅ Koç bitiş bilgisi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_coachFinishText, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text("Kalan görev: $_remainingTasks / 3",
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text("Kalan süre: $_remainingMinutes dk (hedef: $_dailyTarget)",
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _CoachTaskRow(
                    title: "Konuşma",
                    subtitle: "10 cümle • mastery (3/3)",
                    minutes: 7,
                    done: _taskSpeak,
                    onChanged: _taskSpeak ? null : (v) => _setCoachTask(_kCoachSpeak, v, label: "Konuşma", minutes: 7),
                    startLabel: "Başlat",
                    onStart: _taskSpeak ? null : _startSpeak,
                  ),
                  const SizedBox(height: 10),
                  _CoachTaskRow(
                    title: "Dinleme",
                    subtitle: "5 cümle dinle + tekrar et",
                    minutes: 4,
                    done: _taskListen,
                    onChanged: _taskListen ? null : (v) => _setCoachTask(_kCoachListen, v, label: "Dinleme", minutes: 4),
                    startLabel: "Başlat",
                    onStart: _taskListen ? null : _startListen,
                  ),
                  const SizedBox(height: 10),
                  _CoachTaskRow(
                    title: "Kelime",
                    subtitle: "10 kelime • hızlı tekrar",
                    minutes: 4,
                    done: _taskVocab,
                    onChanged: _taskVocab ? null : (v) => _setCoachTask(_kCoachVocab, v, label: "Kelime", minutes: 4),
                    startLabel: "Başlat",
                    onStart: _taskVocab ? null : _startVocab,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Günlük hedef", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(label: const Text("15 dk"), selected: _dailyTarget == 15, onSelected: (_) => _setTarget(15)),
                      ChoiceChip(label: const Text("30 dk"), selected: _dailyTarget == 30, onSelected: (_) => _setTarget(30)),
                      ChoiceChip(label: const Text("45 dk"), selected: _dailyTarget == 45, onSelected: (_) => _setTarget(45)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text("Bugün: $_todayDone / $_dailyTarget dk"),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () => _addManual(15), child: const Text("+15 dk ekle"))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () => _addManual(30), child: const Text("+30 dk ekle"))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Son 7 gün", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  ...List.generate(7, (i) {
                    final d = last7Days[i];
                    final minutes = i < _last7.length ? _last7[i] : 0;
                    final w = minutes / maxV;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(width: 42, child: Text(_dayLabel(d), style: const TextStyle(fontWeight: FontWeight.w800))),
                          const SizedBox(width: 10),
                          Expanded(child: LinearProgressIndicator(value: w.clamp(0.0, 1.0))),
                          const SizedBox(width: 10),
                          SizedBox(width: 46, child: Text("$minutes dk", textAlign: TextAlign.right)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (_log != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Son kayıt", style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(_log!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoachTaskRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int minutes;
  final bool done;

  final ValueChanged<bool>? onChanged;

  final String startLabel;
  final VoidCallback? onStart;

  const _CoachTaskRow({
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.done,
    required this.onChanged,
    required this.startLabel,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Row(
        children: [
          Checkbox(value: done, onChanged: (onChanged == null) ? null : (v) => onChanged!(v ?? false)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  color: Colors.white.withOpacity(0.06),
                ),
                child: Text("+$minutes dk", style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: onStart,
                  child: Text(startLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}