import 'package:flutter/material.dart';

import '../ana_ekran.dart';
import '../course/course_catalog.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

import 'module_screen.dart';
import 'module_sections/vocab_screen.dart';
import 'module_sections/mini_pruefung_screen.dart';
import 'settings_screen.dart';
import 'speaking_tab_screen.dart';
import 'study_plan_screen.dart';
import 'weak_words_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const AnaEkran(),
      const _LessonsTab(),
      const SpeakingTabScreen(),
      const _WordsTab(),
      const _TestsTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withOpacity(0.98),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.accent,
            unselectedItemColor: Colors.white.withOpacity(0.65),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Ana Sayfa"),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Dersler"),
              BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: "Konuşma"),
              BottomNavigationBarItem(icon: Icon(Icons.sort_by_alpha_rounded), label: "Kelimeler"),
              BottomNavigationBarItem(icon: Icon(Icons.fact_check_rounded), label: "Testler"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonsTab extends StatelessWidget {
  const _LessonsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dersler"),
        actions: const [SizedBox(width: 6)],
      ),
      body: const _LessonsTabBody(),
    );
  }
}

class _LessonsTabBody extends StatefulWidget {
  const _LessonsTabBody();

  @override
  State<_LessonsTabBody> createState() => _LessonsTabBodyState();
}

class _LessonsTabBodyState extends State<_LessonsTabBody> {
  final ProgressService _progress = ProgressService();

  @override
  Widget build(BuildContext context) {
    final modules = CourseCatalog.modules;
    return FutureBuilder<List<bool>>(
      future: Future.wait(modules.map((m) => _progress.isModuleUnlocked(m.code))),
      builder: (context, snap) {
        final unlocked = snap.data ?? List<bool>.filled(modules.length, false);
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const _ResumeCard(),
            const SizedBox(height: 12),
            ...List.generate(modules.length, (i) {
              final m = modules[i];
              final isUnlocked = i < unlocked.length ? unlocked[i] : false;
              final lockHint = i == 0 ? null : 'Önce ${modules[i - 1].title} modülünü bitir.';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isUnlocked ? 0.10 : 0.06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      isUnlocked ? Icons.play_circle_fill_rounded : Icons.lock_rounded,
                      color: isUnlocked ? AppTheme.accent : Colors.white38,
                      size: 28,
                    ),
                  ),
                  title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isUnlocked ? m.subtitle : lockHint ?? m.subtitle,
                      style: TextStyle(color: Colors.white.withOpacity(isUnlocked ? 0.74 : 0.56), height: 1.25),
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(isUnlocked ? 0.82 : 0.38)),
                  onTap: isUnlocked
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ModuleScreen(module: m)),
                          )
                      : null,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _ResumeCard extends StatefulWidget {
  const _ResumeCard();

  @override
  State<_ResumeCard> createState() => _ResumeCardState();
}

class _ResumeCardState extends State<_ResumeCard> {
  final ProgressService _progress = ProgressService();
  Map<String, String?>? _last;
  ModuleModel? _module;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final last = await _progress.getLastPosition();
    final moduleCode = last["module"];
    ModuleModel? found;
    if (moduleCode != null) {
      for (final m in CourseCatalog.modules) {
        if (m.code == moduleCode) {
          found = m;
          break;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _last = last;
      _module = found;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              SizedBox(width: 10),
              Text("Son kaldığın bölüm yükleniyor..."),
            ],
          ),
        ),
      );
    }

    if (_module == null || _last == null || _last!["module"] == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kaldığın yerden devam", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Henüz kayıtlı bir son konum yok. Modül 1 ile başlayabilirsin."),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accent, size: 30),
        ),
        title: const Text("Kaldığın yerden devam et", style: TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text("${_module!.title} • ${_last!["section"] ?? "devam"}"),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModuleScreen(module: _module!)),
        ),
      ),
    );
  }
}

class _WordsTab extends StatelessWidget {
  const _WordsTab();

  @override
  Widget build(BuildContext context) {
    final modules = CourseCatalog.modules;

    return Scaffold(
      appBar: AppBar(title: const Text("Kelimeler")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: modules.length,
        itemBuilder: (context, i) {
          final ModuleModel m = modules[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.abc_rounded),
              title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text("${m.words.length} kelime"),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VocabScreen(
                    moduleCode: m.code,
                    title: "Wortschatz • ${m.title}",
                    xpReward: 8,
                    words: m.words,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TestsTab extends StatelessWidget {
  const _TestsTab();

  @override
  Widget build(BuildContext context) {
    final modules = CourseCatalog.modules;

    return Scaffold(
      appBar: AppBar(title: const Text("Testler")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: modules.length,
        itemBuilder: (context, i) {
          final m = modules[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.fact_check_rounded),
              title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text("Mini sınav"),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MiniPruefungScreen(
                    moduleCode: m.code,
                    title: "Mini Prüfung • ${m.title}",
                    xpReward: 12,
                    words: m.words,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final ProgressService _progress = ProgressService();
  int _xp = 0;
  int _streak = 0;
  int _totalProgress = 0;
  int _level = 1;
  int _xpIntoLevel = 0;
  int _xpForNextLevel = 100;
  int _dueWrongCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final xp = await _progress.getTotalXp();
    final streak = await _progress.getStreak();
    final totalProgress = await _progress.getTotalProgress();
    final level = await _progress.getLevel();
    final xpIntoLevel = await _progress.getXpIntoCurrentLevel();
    final xpForNextLevel = await _progress.getXpForNextLevel();
    final dueWrongCount = await _progress.getDueWrongWordCount();

    if (!mounted) return;
    setState(() {
      _xp = xp;
      _streak = streak;
      _totalProgress = totalProgress;
      _level = level;
      _xpIntoLevel = xpIntoLevel;
      _xpForNextLevel = xpForNextLevel;
      _dueWrongCount = dueWrongCount;
      _loading = false;
    });
  }

  Future<void> _openWeakWords() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeakWordsScreen()),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final levelProgress = _xpForNextLevel <= 0
        ? 0.0
        : (_xpIntoLevel / _xpForNextLevel).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _loading
                    ? const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kontrol Merkezi", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.accent),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Level $_level", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$_xpIntoLevel / $_xpForNextLevel XP',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.72),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: levelProgress,
                                    minHeight: 9,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _StatMiniCard(label: "XP", value: _xp.toString())),
                              const SizedBox(width: 8),
                              Expanded(child: _StatMiniCard(label: "Seri", value: "$_streak gün")),
                              const SizedBox(width: 8),
                              Expanded(child: _StatMiniCard(label: "İlerleme", value: "%$_totalProgress")),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _StatMiniCard(
                                  label: "Tekrar",
                                  value: _dueWrongCount == 0 ? "Temiz" : "$_dueWrongCount kelime",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 74,
                                  child: ElevatedButton.icon(
                                    onPressed: _openWeakWords,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text(
                                      "Zayıf\nKelimeler",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            _ProfileActionCard(
              icon: Icons.local_fire_department_rounded,
              title: "Çalışma Planı",
              subtitle: "Günlük hedef, seri ve koç görevleri",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudyPlanScreen()),
                );
                await _load();
              },
            ),
            const SizedBox(height: 10),
            _ProfileActionCard(
              icon: Icons.refresh_rounded,
              title: "Tekrar Edilecek Kelimeler",
              subtitle: _loading
                  ? "Yükleniyor..."
                  : (_dueWrongCount == 0
                      ? "Şu anda zamanı gelen kelime yok"
                      : "$_dueWrongCount kelime tekrar zamanı bekliyor"),
              onTap: _openWeakWords,
            ),
            const SizedBox(height: 10),
            _ProfileActionCard(
              icon: Icons.settings_rounded,
              title: "Ayarlar",
              subtitle: "İlerleme sıfırla, ses araçları ve sistem ayarları",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                await _load();
              },
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Durum", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _loading
                          ? "İstatistikler hazırlanıyor..."
                          : (_dueWrongCount == 0
                              ? "Tekrar tarafı temiz görünüyor. Şimdi yeni derslere yüklenebilirsin."
                              : "Tekrar zamanı gelen kelimeler var. Önce onları toparlamak iyi fikir."),
                      style: TextStyle(color: Colors.white.withOpacity(0.72)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatMiniCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.accent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
