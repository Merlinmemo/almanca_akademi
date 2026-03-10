import 'dart:math';

import 'package:flutter/material.dart';

import '../../modules/modul1/modul1_course_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

class Modul1UnitLessonScreen extends StatefulWidget {
  final Modul1Unit unit;
  const Modul1UnitLessonScreen({super.key, required this.unit});

  @override
  State<Modul1UnitLessonScreen> createState() => _Modul1UnitLessonScreenState();
}

class _Modul1UnitLessonScreenState extends State<Modul1UnitLessonScreen> {
  final ProgressService _p = ProgressService();
  late List<Modul1LessonEntry> _entries;
  bool _done = false;
  int _index = 0;
  bool _shuffled = false;

  Modul1LessonEntry get _entry => _entries[_index];
  bool get _isLast => _index == _entries.length - 1;

  @override
  void initState() {
    super.initState();
    // İlk turda sıra bozulmasın. Kullanıcı önce konuyu düzenli görsün.
    _entries = List<Modul1LessonEntry>.from(widget.unit.entries);
    _load();
  }

  Future<void> _load() async {
    final done = await _p.isSectionCompleted('modul1', widget.unit.key);
    if (!mounted) return;
    setState(() => _done = done);
  }

  Future<void> _speak(String text, {bool slow = false}) async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(text, rate: slow ? 0.78 : 1.0);
  }

  void _shuffleEntries() {
    setState(() {
      _entries = List<Modul1LessonEntry>.from(widget.unit.entries)..shuffle(Random());
      _index = 0;
      _shuffled = true;
    });
  }

  void _resetOrdered() {
    setState(() {
      _entries = List<Modul1LessonEntry>.from(widget.unit.entries);
      _index = 0;
      _shuffled = false;
    });
  }

  Future<void> _complete() async {
    await _p.completeSection(
      moduleCode: 'modul1',
      sectionKey: widget.unit.key,
      xpReward: widget.unit.xpReward,
    );
    if (!mounted) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text('${widget.unit.title} tamamlandı. +${widget.unit.xpReward} XP'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _entries.length;
    final e = _entry;

    return CoursePage(
      title: widget.unit.title,
      subtitle: _shuffled ? 'Karışık tekrar modu' : 'Sıralı öğrenme',
      leadingIcon: widget.unit.icon,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _index == 0 ? null : () => setState(() => _index--),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Önceki'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_isLast) {
                    _complete();
                    return;
                  }
                  setState(() => _index++);
                },
                icon: Icon(_isLast ? Icons.verified_rounded : Icons.arrow_forward_rounded),
                label: Text(_isLast ? 'Bitir (+${widget.unit.xpReward} XP)' : 'Sonraki'),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: 'Modül 1',
            title: widget.unit.title,
            subtitle: '${_entries.length} kart',
            icon: widget.unit.icon,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_index + 1}/${_entries.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                  const SizedBox(height: 2),
                  const Text('kart', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'İlerleme %${(progress * 100).round()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: (_shuffled ? AppTheme.accent : AppTheme.success).withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _shuffled ? 'Karışık tekrar' : 'Sıralı öğrenme',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _shuffled ? AppTheme.accent : AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.de,
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.0),
                          ),
                          const SizedBox(height: 12),
                          Text(e.tr, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text('Okunuş: ${e.pron}', style: TextStyle(fontSize: 14.5, color: Colors.white.withOpacity(0.86), fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _speak(e.de),
                          icon: const Icon(Icons.volume_up_rounded, size: 30),
                        ),
                        IconButton(
                          onPressed: () => _speak(e.de, slow: true),
                          icon: const Icon(Icons.slow_motion_video_rounded, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Alfabe')),
                    Chip(label: Text('Sesli dinleme')),
                    Chip(label: Text('Örnekli anlatım')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Örnek kullanım', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.exampleDe, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.25)),
                          const SizedBox(height: 8),
                          Text(e.exampleTr, style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(0.78), fontWeight: FontWeight.w700, height: 1.35)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(onPressed: () => _speak(e.exampleDe), icon: const Icon(Icons.campaign_rounded)),
                        IconButton(onPressed: () => _speak(e.exampleDe, slow: true), icon: const Icon(Icons.slow_motion_video_rounded)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mini not', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                const SizedBox(height: 10),
                Text(e.note, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.84), fontWeight: FontWeight.w700, height: 1.45)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shuffled ? _resetOrdered : _shuffleEntries,
                        icon: Icon(_shuffled ? Icons.format_list_numbered_rounded : Icons.shuffle_rounded),
                        label: Text(_shuffled ? 'Sıralı akışa dön' : 'Karışık tekrar aç'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
