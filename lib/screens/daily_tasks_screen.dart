
import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'study_plan_screen.dart';
import 'weak_words_screen.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final ProgressService _progress = ProgressService();

  Future<List<dynamic>> _load() {
    return Future.wait([
      _progress.getDailyProgress(),
      _progress.getDailyGoals(),
      _progress.getDailyCompletionRate(),
      _progress.getStreak(),
      _progress.isDailyMissionCompleted(),
      _progress.getTodayDoneMinutes(),
      _progress.getDailyTargetMinutes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Görev Merkezi')),
      body: FutureBuilder<List<dynamic>>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = (snap.data![0] as Map<String, int>);
          final goals = (snap.data![1] as Map<String, int>);
          final rate = (snap.data![2] as double).clamp(0.0, 1.0);
          final streak = (snap.data![3] as int);
          final completed = (snap.data![4] as bool);
          final doneMinutes = (snap.data![5] as int);
          final targetMinutes = (snap.data![6] as int);

          Widget item({
            required IconData icon,
            required String title,
            required String subtitle,
            required int done,
            required int goal,
          }) {
            final isDone = done >= goal;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: (isDone ? AppTheme.success : AppTheme.accent).withOpacity(0.12),
                    ),
                    child: Icon(icon, color: isDone ? AppTheme.success : AppTheme.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.70),
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withOpacity(0.08),
                    ),
                    child: Text(
                      '$done / $goal',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: completed
                          ? const [Color(0xFF184432), Color(0xFF113125)]
                          : const [Color(0xFF15314D), Color(0xFF0D2137)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            completed ? '✅ Bugün temiz' : '🔥 Günlük görev aktif',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.10),
                            ),
                            child: Text(
                              'Seri $streak',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completed ? AppTheme.success : AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        completed
                            ? 'Bugünkü dört görevin de tamamlandı. Seri kırılmadan devam.'
                            : 'Kelime, dinleme, konuşma ve mini test görevlerini tamamla.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                item(
                  icon: Icons.abc_rounded,
                  title: 'Kelime görevi',
                  subtitle: 'Yeni kelimeyi gör, duy ve eşleştir.',
                  done: progress['vocab'] ?? 0,
                  goal: goals['vocab'] ?? 5,
                ),
                const SizedBox(height: 10),
                item(
                  icon: Icons.headphones_rounded,
                  title: 'Dinleme görevi',
                  subtitle: 'Kulağı Alman ritmine alıştır.',
                  done: progress['listening'] ?? 0,
                  goal: goals['listening'] ?? 2,
                ),
                const SizedBox(height: 10),
                item(
                  icon: Icons.mic_rounded,
                  title: 'Konuşma görevi',
                  subtitle: 'Söyle, tekrar et, ağzı aç.',
                  done: progress['speaking'] ?? 0,
                  goal: goals['speaking'] ?? 2,
                ),
                const SizedBox(height: 10),
                item(
                  icon: Icons.fact_check_rounded,
                  title: 'Mini test görevi',
                  subtitle: 'Günün kontrolünü yap.',
                  done: progress['quiz'] ?? 0,
                  goal: goals['quiz'] ?? 1,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppTheme.accent.withOpacity(0.12),
                        ),
                        child: const Icon(Icons.schedule_rounded, color: AppTheme.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Çalışma planı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                            const SizedBox(height: 3),
                            Text(
                              '$doneMinutes / $targetMinutes dk bugün işlendi',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.70),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StudyPlanScreen()),
                          );
                          if (mounted) setState(() {});
                        },
                        child: const Text('Aç'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFFFB84D).withOpacity(0.14),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Color(0xFFFFB84D)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weak Words Merkezi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                            const SizedBox(height: 3),
                            Text(
                              'Yanlış yaptığın kelimeleri tek yerden aç, dinle ve havuzu temizle.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.70),
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WeakWordsScreen()),
                          );
                          if (mounted) setState(() {});
                        },
                        child: const Text('Git'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
