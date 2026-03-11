import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course/course_catalog.dart';
import 'models/module_model.dart';
import 'models/word_model.dart';
import 'services/progress_service.dart';
import 'services/tts_service.dart';

import 'screens/module_screen.dart';
import 'screens/study_plan_screen.dart';
import 'screens/module_sections/intro_screen.dart';
import 'screens/module_sections/vocab_screen.dart';
import 'screens/module_sections/satzbau_screen.dart';
import 'screens/module_sections/hoeren_screen.dart';
import 'screens/module_sections/sprechen_screen.dart';
import 'screens/module_sections/mini_pruefung_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

enum _CoachNext { speak, listen, vocab }

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final ProgressService _p = ProgressService();
  late final List<ModuleModel> _modules = CourseCatalog.modules;
  final Map<String, bool> _completedCache = {};

  static const _kCoachSpeak = "coachTaskSpeak";
  static const _kCoachListen = "coachTaskListen";
  static const _kCoachVocab = "coachTaskVocab";

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _p.ensureCourseBoot();
    for (final m in _modules) {
      _completedCache[m.code] = await _p.isModuleCompleted(m.code);
    }
    if (mounted) setState(() {});
  }

  String _kCoachKey(String base, String ymd) => "${base}_$ymd";

  Future<String> _pickCoachModuleCode() async {
    String? firstUnlocked;
    String? firstUnlockedNotCompleted;

    for (final code in CourseCatalog.moduleCodes) {
      final unlocked = await _p.isModuleUnlocked(code);
      if (!unlocked) continue;

      firstUnlocked ??= code;

      final completed = await _p.isModuleCompleted(code);
      if (!completed) {
        firstUnlockedNotCompleted ??= code;
      }
    }

    return firstUnlockedNotCompleted ??
        firstUnlocked ??
        CourseCatalog.firstModuleCode;
  }

  Future<_CoachNext?> _nextCoachTask() async {
    final prefs = await SharedPreferences.getInstance();
    final ymd = ProgressService.todayYmd();

    final s = prefs.getBool(_kCoachKey(_kCoachSpeak, ymd)) ?? false;
    final l = prefs.getBool(_kCoachKey(_kCoachListen, ymd)) ?? false;
    final v = prefs.getBool(_kCoachKey(_kCoachVocab, ymd)) ?? false;

    if (!s) return _CoachNext.speak;
    if (!l) return _CoachNext.listen;
    if (!v) return _CoachNext.vocab;
    return null;
  }

  Future<void> _checkNewBadgeAndToast(String moduleCode) async {
    final was = _completedCache[moduleCode] ?? false;
    final now = await _p.isModuleCompleted(moduleCode);
    _completedCache[moduleCode] = now;

    if (!was && now && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎖️ Yeni rozet: $moduleCode"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  ModuleSectionType _typeFromSectionKey(String key) {
    switch (key) {
      case "intro":
        return ModuleSectionType.intro;
      case "vocab":
        return ModuleSectionType.vocab;
      case "sentence":
        return ModuleSectionType.sentence;
      case "listen":
        return ModuleSectionType.listen;
      case "speak":
        return ModuleSectionType.speak;
      case "exam":
        return ModuleSectionType.exam;
      default:
        return ModuleSectionType.intro;
    }
  }

  Future<void> _startCoachTask(_CoachNext task) async {
    final moduleCode = await _pickCoachModuleCode();
    final m = _modules.firstWhere(
      (x) => x.code == moduleCode,
      orElse: () => _modules.first,
    );

    late final Widget page;

    if (task == _CoachNext.speak) {
      page = SprechenScreen(
        moduleCode: moduleCode,
        title: "Sprechen • Koç",
        xpReward: 10,
      );
    } else if (task == _CoachNext.listen) {
      page = HoerenScreen(
        moduleCode: moduleCode,
        title: "Hören • Koç",
        xpReward: 8,
        prompts: m.words,
      );
    } else {
      page = VocabScreen(
        moduleCode: moduleCode,
        title: "Wortschatz • Koç",
        xpReward: 8,
        words: m.words,
      );
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _checkNewBadgeAndToast(moduleCode);
    if (mounted) setState(() {});
  }

  Future<void> _continueLast() async {
    await _p.ensureCourseBoot();

    final dueWords = await _buildWrongPoolWords();
    if (dueWords.isNotEmpty) {
      await _openWrongWordsReview();
      return;
    }

    final last = await _p.getLastPosition();
    final moduleCode = last["module"];
    final sectionKey = last["section"];

    if (moduleCode == null || sectionKey == null) {
      final firstCode = await _pickCoachModuleCode();
      final m = _modules.firstWhere(
        (x) => x.code == firstCode,
        orElse: () => _modules.first,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ModuleScreen(module: m)),
      );
      await _checkNewBadgeAndToast(m.code);
      if (mounted) setState(() {});
      return;
    }

    final m = _modules.firstWhere(
      (x) => x.code == moduleCode,
      orElse: () => _modules.first,
    );

    late final Widget page;

    if (moduleCode == 'modul1' && sectionKey != 'intro') {
      page = ModuleScreen(module: m);
    } else {
      final type = _typeFromSectionKey(sectionKey);
      final sec = m.sections.firstWhere(
        (s) => s.type == type,
        orElse: () => m.sections.first,
      );

      if (type == ModuleSectionType.intro) {
        page = IntroScreen(
          moduleCode: m.code,
          title: sec.title,
          description: sec.description,
          xpReward: sec.xpReward,
        );
      } else if (type == ModuleSectionType.vocab) {
        page = VocabScreen(
          moduleCode: m.code,
          title: sec.title,
          xpReward: sec.xpReward,
          words: m.words,
        );
      } else if (type == ModuleSectionType.sentence) {
        page = SatzbauScreen(
          moduleCode: m.code,
          title: sec.title,
          xpReward: sec.xpReward,
        );
      } else if (type == ModuleSectionType.listen) {
        page = HoerenScreen(
          moduleCode: m.code,
          title: sec.title,
          xpReward: sec.xpReward,
          prompts: m.words,
        );
      } else if (type == ModuleSectionType.speak) {
        page = SprechenScreen(
          moduleCode: m.code,
          title: sec.title,
          xpReward: sec.xpReward,
        );
      } else {
        page = MiniPruefungScreen(
          moduleCode: m.code,
          title: sec.title,
          xpReward: sec.xpReward,
          words: m.words,
        );
      }
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _checkNewBadgeAndToast(m.code);
    if (mounted) setState(() {});
  }

  Future<void> _openStudyPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyPlanScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (changed == true) {
      for (final m in _modules) {
        _completedCache[m.code] = await _p.isModuleCompleted(m.code);
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _openLessonsHub() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LessonsHubScreen(
          modules: _modules,
          p: _p,
          onOpen: (m) async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ModuleScreen(module: m)),
            );
            await _checkNewBadgeAndToast(m.code);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _openLatestVocab() async {
    final moduleCode = await _pickCoachModuleCode();
    final m = _modules.firstWhere(
      (x) => x.code == moduleCode,
      orElse: () => _modules.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ModuleScreen(module: m)),
    );
    await _checkNewBadgeAndToast(m.code);
    if (mounted) setState(() {});
  }

  Future<void> _openLatestSatzbau() async {
    final moduleCode = await _pickCoachModuleCode();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SatzbauScreen(
          moduleCode: moduleCode,
          title: "Satzbau • Hızlı",
          xpReward: 8,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openLatestListen() async {
    final moduleCode = await _pickCoachModuleCode();
    final m = _modules.firstWhere(
      (x) => x.code == moduleCode,
      orElse: () => _modules.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HoerenScreen(
          moduleCode: moduleCode,
          title: "Hören • Hızlı",
          xpReward: 8,
          prompts: m.words,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openLatestExam() async {
    final moduleCode = await _pickCoachModuleCode();
    final m = _modules.firstWhere(
      (x) => x.code == moduleCode,
      orElse: () => _modules.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiniPruefungScreen(
          moduleCode: moduleCode,
          title: "Mini Prüfung • Hızlı",
          xpReward: 12,
          words: m.words,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<List<WordItem>> _buildWrongPoolWords() async {
    final wrongs = await _p.getDueWrongWords();
    if (wrongs.isEmpty) return [];

    final wanted = wrongs
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    final out = <WordItem>[];
    final seen = <String>{};

    for (final m in _modules) {
      for (final w in m.words) {
        final key = w.de.trim().toLowerCase();
        if (wanted.contains(key) && !seen.contains(key)) {
          out.add(w);
          seen.add(key);
        }
      }
    }
    return out;
  }

  Future<void> _openWrongWordsReview() async {
    final words = await _buildWrongPoolWords();
    if (words.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bugün tekrar edilmesi gereken kelime yok.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabScreen(
          moduleCode: 'wrong_pool',
          title: 'Tekrar Edilecek Kelimeler',
          xpReward: 6,
          words: words,
        ),
      ),
    );

    if (mounted) setState(() {});
  }

  Future<void> _speakWord() async {
    await TtsService.I.speakDe("das Auto");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 18 + bottomInset),
          children: [
            _TopBar(onSettings: _openSettings),
            const SizedBox(height: 14),
            _ContinueCard(onContinue: _continueLast),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Hızlı Başlangıç',
              subtitle: 'En çok kullanılan bölümlere tek dokunuşla git.',
            ),
            const SizedBox(height: 10),
            _QuickGrid(
              tiles: [
                _QuickTileData(
                  title: 'Dersler',
                  subtitle: 'Konular',
                  icon: Icons.menu_book_rounded,
                  onTap: _openLessonsHub,
                ),
                _QuickTileData(
                  title: 'Kelimeler',
                  subtitle: 'Sözlük',
                  icon: Icons.abc_rounded,
                  onTap: _openLatestVocab,
                ),
                _QuickTileData(
                  title: 'Cümleler',
                  subtitle: 'Örnekler',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: _openLatestSatzbau,
                ),
                _QuickTileData(
                  title: 'Dinleme',
                  subtitle: 'Pratik',
                  icon: Icons.headphones_rounded,
                  onTap: _openLatestListen,
                ),
                _QuickTileData(
                  title: 'Yazma',
                  subtitle: 'Alıştırma',
                  icon: Icons.edit_note_rounded,
                  onTap: () => _toast('Yazma yakında.'),
                ),
                _QuickTileData(
                  title: 'Testler',
                  subtitle: 'Mini sınav',
                  icon: Icons.fact_check_rounded,
                  onTap: _openLatestExam,
                  badge: 'Yeni',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _WordCard(
                    wordDe: 'das Auto',
                    wordTr: 'Araba',
                    onSpeak: _speakWord,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DailyGoalCard(
                    p: _p,
                    onContinue: _continueLast,
                    onPlan: _openStudyPlan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Tekrar',
              subtitle: 'Bugün zayıf kaldığın kelimeleri tek yerden toparla.',
            ),
            const SizedBox(height: 10),
            _WrongWordsCard(p: _p, onOpen: _openWrongWordsReview),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSettings;
  const _TopBar({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.10),
          ),
          child: const Center(
            child: Text('🇩🇪', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Almanca Akademi',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'A1 → A2 → B1 → B2',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Ayarlar',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_rounded, size: 22),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final VoidCallback onContinue;
  const _ContinueCard({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 162,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: AssetImage('assets/ui/academy_home_metal.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.30),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withOpacity(0.92),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_graph_rounded, size: 14, color: Colors.black87),
                  SizedBox(width: 6),
                  Text(
                    'Seviye: A1',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kaldığın yerden devam et',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Devam Et',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
      ],
    );
  }
}

class _QuickTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  _QuickTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badge,
  });
}

class _QuickGrid extends StatelessWidget {
  final List<_QuickTileData> tiles;
  const _QuickGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 10.0;
        final itemW = (c.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles.map((t) {
            return SizedBox(
              width: itemW,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: t.onTap,
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF163553),
                          Color(0xFF0E2A47),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: t.badge == null
                              ? const SizedBox(height: 18)
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5148),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    t.badge!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.10),
                          ),
                          child: Icon(
                            t.icon,
                            color: AppTheme.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _WordCard extends StatelessWidget {
  final String wordDe;
  final String wordTr;
  final VoidCallback onSpeak;

  const _WordCard({
    required this.wordDe,
    required this.wordTr,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/ui/academy_gold_panel.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Günün Kelimesi',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  wordDe,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: onSpeak,
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '→ $wordTr',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final ProgressService p;
  final VoidCallback onContinue;
  final VoidCallback onPlan;

  const _DailyGoalCard({
    required this.p,
    required this.onContinue,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        p.getDailyProgress(),
        p.getDailyGoals(),
        p.getDailyCompletionRate(),
        p.getStreak(),
        p.isDailyMissionCompleted(),
      ]),
      builder: (context, snap) {
        final progress = (snap.data?[0] as Map<String, int>?) ??
            const {
              'vocab': 0,
              'listening': 0,
              'speaking': 0,
              'quiz': 0,
            };

        final goals = (snap.data?[1] as Map<String, int>?) ??
            const {
              'vocab': 5,
              'listening': 2,
              'speaking': 2,
              'quiz': 1,
            };

        final ratio = ((snap.data?[2] as double?) ?? 0.0).clamp(0.0, 1.0);
        final streak = (snap.data?[3] as int?) ?? 0;
        final completed = (snap.data?[4] as bool?) ?? false;

        final totalDone =
            (progress['vocab'] ?? 0) +
            (progress['listening'] ?? 0) +
            (progress['speaking'] ?? 0) +
            (progress['quiz'] ?? 0);

        final totalGoal =
            (goals['vocab'] ?? 5) +
            (goals['listening'] ?? 2) +
            (goals['speaking'] ?? 2) +
            (goals['quiz'] ?? 1);

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onContinue,
          child: Container(
            height: 156,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: completed
                  ? const Color(0xFF143A2A)
                  : const Color(0xFF0F2E5E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        completed ? '✅ Gün tamam' : '🔥 Günlük Görev',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.12),
                      ),
                      child: Text(
                        'Seri $streak',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalDone / $totalGoal adım',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelime • Dinleme • Konuşma • Quiz',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? const Color(0xFF6EF3B1) : AppTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    completed ? 'Dokun ve sürdür' : 'Dokun ve devam et',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WrongWordsCard extends StatelessWidget {
  final ProgressService p;
  final VoidCallback onOpen;
  const _WrongWordsCard({required this.p, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: p.getDueWrongWords(),
      builder: (context, snap) {
        final words = snap.data ?? const <String>[];
        final count = words.length;
        final hasItems = count > 0;
        final preview = hasItems
            ? words.take(3).join(' • ')
            : 'Harika. Zayıf kelime havuzu şu an boş.';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: hasItems ? const Color(0xFF3A1E12) : const Color(0xFF123B73),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.12),
                ),
                child: Icon(
                  hasItems ? Icons.refresh_rounded : Icons.verified_rounded,
                  color: hasItems ? AppTheme.accent : const Color(0xFF6EF3B1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasItems
                          ? 'Tekrar Edilecek Kelimeler'
                          : 'Zayıf Kelime Havuzu Temiz',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasItems
                          ? '$count kelime seni bekliyor'
                          : 'Yanlış yaptığın kelimeler burada birikecek.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    hasItems ? 'Tekrar Et' : 'Aç',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonsHubScreen extends StatelessWidget {
  final List<ModuleModel> modules;
  final ProgressService p;
  final Future<void> Function(ModuleModel m) onOpen;

  const _LessonsHubScreen({
    required this.modules,
    required this.p,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(title: const Text('Dersler')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        children: [
          Text(
            'Modüller',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 8),
          ...modules.map((m) {
            return FutureBuilder<bool>(
              future: p.isModuleUnlocked(m.code),
              builder: (context, snap) {
                final unlocked = snap.data ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: unlocked ? () => onOpen(m) : null,
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                              ),
                            ),
                            child: Icon(
                              unlocked
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.lock_rounded,
                              color: unlocked ? AppTheme.accent : Colors.white38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.subtitle,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}