import 'package:flutter/material.dart';

import '../../models/generated_content_models.dart';
import '../../services/content_engine/sentence_engine.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';
import 'satzbau_screen.dart';

class MicroSentenceScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;

  const MicroSentenceScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
  });

  @override
  State<MicroSentenceScreen> createState() => _MicroSentenceScreenState();
}

class _MicroSentenceScreenState extends State<MicroSentenceScreen> {
  final ProgressService _p = ProgressService();
  late final List<SentencePattern> _qs = SentenceEngine.I.generatePatternSet(moduleCode: widget.moduleCode, level: 1, count: 5);
  int _i = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;
  SentencePattern get _q => _qs[_i];

  Future<void> _play() async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(_q.exampleDe);
  }

  void _check() {
    if (_selected == null) return;
    final ok = _selected == _q.correctIndex;
    setState(() {
      _checked = true;
      if (ok) _correct++;
    });
  }

  Future<void> _nextOrFinish() async {
    if (_i < _qs.length - 1) {
      setState(() {
        _i++;
        _selected = null;
        _checked = false;
      });
      return;
    }

    await _p.completeSection(moduleCode: widget.moduleCode, sectionKey: 'micro', xpReward: widget.xpReward);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mikro tamamlandı ✅'),
        content: Text('Doğru: $_correct / ${_qs.length}\n\nŞimdi Satzbau bölümüne geçiyoruz.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Devam'))],
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SatzbauScreen(moduleCode: widget.moduleCode, title: 'Satzbau', xpReward: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_qs.isEmpty) {
      return const Scaffold(body: Center(child: Text('Micro içerik bulunamadı.')));
    }
    final total = _qs.length;
    final progress = ((_i + 1) / total).clamp(0.0, 1.0);
    return CoursePage(
      title: widget.title,
      subtitle: 'Hızlı cümle refleksi',
      leadingIcon: Icons.flash_on_rounded,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: (_selected == null || _checked) ? null : _check, child: const Text('Kontrol Et'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: !_checked ? null : _nextOrFinish, child: Text(_i == total - 1 ? 'Bitir' : 'Devam'))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Soru ${_i + 1} / $total', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 12),
              Text('${_q.microRuleTitle}: ${_q.microRuleText}', style: TextStyle(color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_q.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
              const SizedBox(height: 10),
              Text(_q.exampleDe, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(_q.exampleTr, style: TextStyle(color: Colors.white.withOpacity(0.76), fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _play, icon: const Icon(Icons.volume_up_rounded), label: const Text('Dinle')),
            ]),
          ),
          const SizedBox(height: 14),
          ...List.generate(_q.practiceOptions.length, (idx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppOptionTile(
                title: _q.practiceOptions[idx],
                selected: _selected == idx,
                correct: _checked && idx == _q.correctIndex,
                wrong: _checked && _selected == idx && idx != _q.correctIndex,
                onTap: _checked ? null : () => setState(() => _selected = idx),
              ),
            );
          }),
          if (_checked) ...[
            const SizedBox(height: 4),
            Text(_selected == _q.correctIndex ? '✅ Doğru' : '❌ Yanlış', style: TextStyle(fontWeight: FontWeight.w900, color: _selected == _q.correctIndex ? AppTheme.success : AppTheme.danger, fontSize: 15)),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
