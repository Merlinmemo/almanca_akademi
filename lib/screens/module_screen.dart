import 'package:flutter/material.dart';

import '../models/module_model.dart';
import '../modules/modul1/modul1_course_data.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/course_ui.dart';

import 'module_sections/hoeren_screen.dart';
import 'module_sections/intro_screen.dart';
import 'module_sections/mini_pruefung_screen.dart';
import 'module_sections/micro_sentence_screen.dart';
import 'module_sections/modul1_exam_screen.dart';
import 'module_sections/modul1_listening_screen.dart';
import 'module_sections/modul1_speaking_screen.dart';
import 'module_sections/modul1_unit_lesson_screen.dart';
import 'module_sections/satzbau_screen.dart';
import 'module_sections/sprechen_screen.dart';
import 'module_sections/vocab_screen.dart';

class ModuleScreen extends StatefulWidget {
  final ModuleModel module;
  const ModuleScreen({super.key, required this.module});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final ProgressService _p = ProgressService();

  String _sectionKey(ModuleSectionType t) {
    switch (t) {
      case ModuleSectionType.intro:
        return 'intro';
      case ModuleSectionType.vocab:
        return 'vocab';
      case ModuleSectionType.micro:
        return 'micro';
      case ModuleSectionType.sentence:
        return 'sentence';
      case ModuleSectionType.listen:
        return 'listen';
      case ModuleSectionType.speak:
        return 'speak';
      case ModuleSectionType.exam:
        return 'exam';
    }
  }

  IconData _sectionIcon(ModuleSectionType t) {
    switch (t) {
      case ModuleSectionType.intro:
        return Icons.flag_rounded;
      case ModuleSectionType.vocab:
        return Icons.abc_rounded;
      case ModuleSectionType.micro:
        return Icons.bolt_rounded;
      case ModuleSectionType.sentence:
        return Icons.short_text_rounded;
      case ModuleSectionType.listen:
        return Icons.headphones_rounded;
      case ModuleSectionType.speak:
        return Icons.mic_rounded;
      case ModuleSectionType.exam:
        return Icons.fact_check_rounded;
    }
  }

  String _sectionShortTitle(ModuleSectionType t) {
    switch (t) {
      case ModuleSectionType.intro:
        return 'Giriş / Einführung';
      case ModuleSectionType.vocab:
        return 'Kelimeler / Wörter';
      case ModuleSectionType.micro:
        return 'Hızlı Tekrar / Schnell';
      case ModuleSectionType.sentence:
        return 'Cümle Kurma / Satzbau';
      case ModuleSectionType.listen:
        return 'Dinleme / Hören';
      case ModuleSectionType.speak:
        return 'Konuşma / Sprechen';
      case ModuleSectionType.exam:
        return 'Mini Test / Prüfung';
    }
  }

  Future<bool> _canOpenSection(int index) async {
    if (ProgressService.devUnlockAllModules) return true;
    if (index == 0) return true;

    final m = widget.module;
    final introDone = await _p.isSectionCompleted(m.code, 'intro');
    final vocabDone = await _p.isSectionCompleted(m.code, 'vocab');
    final microDone = await _p.isSectionCompleted(m.code, 'micro');
    final sentDone = await _p.isSectionCompleted(m.code, 'sentence');
    final listenDone = await _p.isSectionCompleted(m.code, 'listen');
    final speakDone = await _p.isSectionCompleted(m.code, 'speak');

    final sec = m.sections[index];
    final key = _sectionKey(sec.type);

    if (key == 'vocab') return introDone;
    if (key == 'micro') return vocabDone;
    if (key == 'sentence') return microDone;
    if (key == 'listen') return sentDone;
    if (key == 'speak') return listenDone;
    if (key == 'exam') return speakDone;

    final prev = m.sections[index - 1];
    return _p.isSectionCompleted(m.code, _sectionKey(prev.type));
  }

  Future<bool> _canOpenModul1Unit(int index) async {
    if (ProgressService.devUnlockAllModules) return true;
    if (index == 0) return true;
    final prevKey = Modul1CourseData.units[index - 1].key;
    return _p.isSectionCompleted('modul1', prevKey);
  }

  Future<void> _openModul1Unit(Modul1Unit unit) async {
    late final Widget page;
    switch (unit.mode) {
      case Modul1UnitMode.lesson:
        page = Modul1UnitLessonScreen(unit: unit);
        break;
      case Modul1UnitMode.listen:
        page = Modul1ListeningScreen(unit: unit);
        break;
      case Modul1UnitMode.speak:
        page = Modul1SpeakingScreen(unit: unit);
        break;
      case Modul1UnitMode.exam:
        page = Modul1ExamScreen(unit: unit);
        break;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openSection(ModuleSection sec) async {
    final m = widget.module;
    late final Widget page;

    if (sec.type == ModuleSectionType.intro) {
      page = IntroScreen(
        moduleCode: m.code,
        title: sec.title,
        description: sec.description,
        xpReward: sec.xpReward,
      );
    } else if (sec.type == ModuleSectionType.vocab) {
      page = VocabScreen(
        moduleCode: m.code,
        title: sec.title,
        xpReward: sec.xpReward,
        words: m.words,
      );
    } else if (sec.type == ModuleSectionType.micro) {
      page = MicroSentenceScreen(
        moduleCode: m.code,
        title: sec.title,
        xpReward: sec.xpReward,
      );
    } else if (sec.type == ModuleSectionType.sentence) {
      page = SatzbauScreen(
        moduleCode: m.code,
        title: sec.title,
        xpReward: sec.xpReward,
      );
    } else if (sec.type == ModuleSectionType.listen) {
      page = HoerenScreen(
        moduleCode: m.code,
        title: sec.title,
        xpReward: sec.xpReward,
      );
    } else if (sec.type == ModuleSectionType.speak) {
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

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (!mounted) return;
    setState(() {});
  }

  Future<_ModuleOverviewData> _buildOverviewData() async {
    final module = widget.module;
    final progress = (await _p.getModuleProgress(module.code)).clamp(0, 100);

    if (module.code == 'modul1') {
      int completedCount = 0;
      String nextTitle = 'Bu modülün ilk adımı hazır';

      for (int i = 0; i < Modul1CourseData.units.length; i++) {
        final unit = Modul1CourseData.units[i];
        final done = await _p.isSectionCompleted('modul1', unit.key);
        if (done) {
          completedCount++;
        } else {
          nextTitle = unit.title;
          break;
        }
      }

      if (completedCount >= Modul1CourseData.units.length) {
        nextTitle = 'Tüm adımlar tamamlandı';
      }

      return _ModuleOverviewData(
        progress: progress,
        completedCount: completedCount,
        totalCount: Modul1CourseData.units.length,
        nextTitle: nextTitle,
      );
    }

    int completedCount = 0;
    String nextTitle = 'İlk bölüme başlayabilirsin';

    for (final sec in module.sections) {
      final done = await _p.isSectionCompleted(module.code, _sectionKey(sec.type));
      if (done) {
        completedCount++;
      } else {
        nextTitle = _sectionShortTitle(sec.type);
        break;
      }
    }

    if (completedCount >= module.sections.length) {
      nextTitle = 'Tüm bölümler tamamlandı';
    }

    return _ModuleOverviewData(
      progress: progress,
      completedCount: completedCount,
      totalCount: module.sections.length,
      nextTitle: nextTitle,
    );
  }

  Widget _pathHeader() {
    return FutureBuilder<_ModuleOverviewData>(
      future: _buildOverviewData(),
      builder: (context, snap) {
        final data = snap.data ??
            const _ModuleOverviewData(
              progress: 0,
              completedCount: 0,
              totalCount: 0,
              nextTitle: 'Yükleniyor...',
            );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage('assets/ui/academy_module_metal.png'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.module.title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.module.subtitle,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.white.withOpacity(0.84),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppTheme.accent.withOpacity(0.16),
                        ),
                        child: Text(
                          '%${data.progress} tamam',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: data.progress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.check_circle_rounded,
                          label: 'Tamamlanan',
                          value: '${data.completedCount}/${data.totalCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.flag_rounded,
                          label: 'Sıradaki Adım',
                          value: data.completedCount >= data.totalCount ? 'Bitti' : 'Hazır',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accent.withOpacity(0.16),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Önerilen sonraki adım',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withOpacity(0.72),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.nextTitle,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionNode({
    required String title,
    required IconData icon,
    required bool completed,
    required bool locked,
    required VoidCallback? onTap,
    String? tag,
    bool showLine = true,
  }) {
    final active = !locked;
    final ringColor = completed
        ? AppTheme.success
        : active
            ? AppTheme.accent
            : Colors.white30;

    final List<Color> gradient = completed
        ? [AppTheme.success.withOpacity(0.95), AppTheme.success.withOpacity(0.55)]
        : active
            ? [const Color(0xFF1B4C7A), const Color(0xFF0E2A47)]
            : [Colors.white12, Colors.white10];

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      height: 62,
                      width: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ringColor.withOpacity(active ? 0.30 : 0.12),
                            blurRadius: 18,
                            spreadRadius: -3,
                          ),
                        ],
                        border: Border.all(
                          color: ringColor.withOpacity(0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        completed
                            ? Icons.check_rounded
                            : (locked ? Icons.lock_rounded : icon),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    if (showLine)
                      Container(
                        width: 3,
                        height: 52,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MiniPill(
                                  label: completed
                                      ? 'Bitti'
                                      : (locked ? 'Kilitli' : 'Şimdi'),
                                ),
                                if (tag != null) _MiniPill(label: tag),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        completed
                            ? Icons.verified_rounded
                            : (locked
                                ? Icons.lock_rounded
                                : Icons.chevron_right_rounded),
                        color: ringColor,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modul1Path() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _pathHeader(),
        const SizedBox(height: 16),
        Text(
          'Öğrenme Yolu',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white.withOpacity(0.96),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(Modul1CourseData.units.length, (index) {
          final unit = Modul1CourseData.units[index];
          final tag = unit.mode == Modul1UnitMode.lesson
              ? 'Ders'
              : unit.mode == Modul1UnitMode.listen
                  ? 'Dinleme'
                  : unit.mode == Modul1UnitMode.speak
                      ? 'Konuşma'
                      : 'Test';

          return FutureBuilder<bool>(
            future: _canOpenModul1Unit(index),
            builder: (context, canSnap) {
              final canOpen = canSnap.data ?? false;
              return FutureBuilder<bool>(
                future: _p.isSectionCompleted('modul1', unit.key),
                builder: (context, doneSnap) {
                  final done = doneSnap.data ?? false;
                  return _sectionNode(
                    title: unit.title,
                    icon: unit.icon,
                    completed: done,
                    locked: !canOpen,
                    onTap: canOpen ? () => _openModul1Unit(unit) : null,
                    tag: tag,
                    showLine: index != Modul1CourseData.units.length - 1,
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _genericPath() {
    final m = widget.module;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _pathHeader(),
        const SizedBox(height: 16),
        Text(
          'Öğrenme Yolu',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Colors.white.withOpacity(0.96),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(m.sections.length, (i) {
          final sec = m.sections[i];
          return FutureBuilder<bool>(
            future: _canOpenSection(i),
            builder: (context, canSnap) {
              final canOpen = canSnap.data ?? false;
              return FutureBuilder<bool>(
                future: _p.isSectionCompleted(m.code, _sectionKey(sec.type)),
                builder: (context, doneSnap) {
                  final done = doneSnap.data ?? false;
                  return _sectionNode(
                    title: _sectionShortTitle(sec.type),
                    icon: _sectionIcon(sec.type),
                    completed: done,
                    locked: !canOpen,
                    onTap: canOpen ? () => _openSection(sec) : null,
                    tag: '${sec.xpReward} XP',
                    showLine: i != m.sections.length - 1,
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;

    return FutureBuilder<bool>(
      future: _p.isModuleUnlocked(m.code),
      builder: (context, snap) {
        final unlocked = snap.data ?? false;

        return CoursePage(
          title: m.title,
          subtitle: '',
          leadingIcon: Icons.school_rounded,
          body: unlocked
              ? (m.code == 'modul1' ? _modul1Path() : _genericPath())
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: const [
                    AppCard(
                      child: Row(
                        children: [
                          Icon(Icons.lock_rounded, color: Colors.white54),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bu modül henüz kilitli. Önce önceki modülü bitir.',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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

class _MiniPill extends StatelessWidget {
  final String label;
  const _MiniPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _ModuleOverviewData {
  final int progress;
  final int completedCount;
  final int totalCount;
  final String nextTitle;

  const _ModuleOverviewData({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.nextTitle,
  });
}