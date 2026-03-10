
import 'package:flutter/material.dart';

import '../course/course_catalog.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'module_sections/sprechen_screen.dart';

class SpeakingTabScreen extends StatefulWidget {
  const SpeakingTabScreen({super.key});

  @override
  State<SpeakingTabScreen> createState() => _SpeakingTabScreenState();
}

class _SpeakingTabScreenState extends State<SpeakingTabScreen> {
  final ProgressService _progress = ProgressService();

  Future<void> _openSpeaking(BuildContext context, ModuleModel module) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SprechenScreen(
          moduleCode: module.code,
          title: "Konuşma • ${module.title}",
          xpReward: 10,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final modules = CourseCatalog.modules;
    return Scaffold(
      appBar: AppBar(title: const Text("Konuşma")),
      body: FutureBuilder<List<bool>>(
        future: Future.wait(modules.map((m) => _progress.isModuleUnlocked(m.code))),
        builder: (context, snap) {
          final unlocked = snap.data ?? List<bool>.filled(modules.length, true);
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF173450), Color(0xFF0E2439)],
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
                    const Row(
                      children: [
                        Icon(Icons.mic_rounded, color: AppTheme.accent, size: 26),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Konuşarak öğren",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Almanca cümleleri sesli tekrar et, modül modül konuşma pratiği yap ve ağzın Almancaya alışsın.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.76),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _SpeakingPill(icon: Icons.record_voice_over_rounded, text: "Telaffuz"),
                        _SpeakingPill(icon: Icons.repeat_rounded, text: "Tekrar"),
                        _SpeakingPill(icon: Icons.auto_graph_rounded, text: "+10 XP"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _QuickSpeakingCard(
                title: "Hızlı Konuşma Başlat",
                subtitle: "Şu an açık olan modülden konuşma pratiğine gir.",
                icon: Icons.flash_on_rounded,
                onTap: () async {
                  ModuleModel? firstOpen;
                  for (final m in modules) {
                    final isUnlocked = await _progress.isModuleUnlocked(m.code);
                    if (isUnlocked) {
                      firstOpen = m;
                      break;
                    }
                  }
                  firstOpen ??= modules.first;
                  if (!context.mounted) return;
                  await _openSpeaking(context, firstOpen);
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Modül Bazlı Konuşma",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: 10),
              ...List.generate(modules.length, (i) {
                final module = modules[i];
                final isUnlocked = i < unlocked.length ? unlocked[i] : true;
                return FutureBuilder<int>(
                  future: _progress.getModuleProgress(module.code),
                  builder: (context, progressSnap) {
                    final progress = (progressSnap.data ?? 0).clamp(0, 100);
                    final accent = isUnlocked ? AppTheme.accent : Colors.white38;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: isUnlocked ? () => _openSpeaking(context, module) : null,
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white.withOpacity(isUnlocked ? 0.055 : 0.03),
                            border: Border.all(
                              color: accent.withOpacity(isUnlocked ? 0.24 : 0.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: accent.withOpacity(0.12),
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.mic_rounded : Icons.lock_rounded,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      module.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isUnlocked
                                          ? "Konuşma pratiğini başlat • ${module.estimatedMinutes} dk"
                                          : "Bu modül kilitli.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.72),
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: progress / 100,
                                        minHeight: 7,
                                        backgroundColor: Colors.white12,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isUnlocked ? AppTheme.accent : Colors.white24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _SpeakingMiniPill(
                                          icon: Icons.percent_rounded,
                                          text: "%$progress",
                                          color: accent,
                                        ),
                                        _SpeakingMiniPill(
                                          icon: Icons.workspace_premium_rounded,
                                          text: "+10 XP",
                                          color: accent,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withOpacity(isUnlocked ? 0.72 : 0.30),
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
          );
        },
      ),
    );
  }
}

class _QuickSpeakingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickSpeakingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(0.055),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppTheme.accent.withOpacity(0.12),
              ),
              child: const Icon(Icons.mic_external_on_rounded, color: AppTheme.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeakingPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SpeakingPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _SpeakingMiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SpeakingMiniPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }
}
