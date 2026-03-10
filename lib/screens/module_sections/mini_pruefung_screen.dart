
// mini_pruefung_screen.dart – Weak Words sistemi bağlandı
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/content_engine/word_engine.dart';
import '../../services/progress_service.dart';
import '../../widgets/course_ui.dart';

class _Q {
  final String promptDe;
  final List<String> optionsTr;
  final int correctIndex;
  const _Q({required this.promptDe, required this.optionsTr, required this.correctIndex});
}

class MiniPruefungScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;
  final List<WordItem> words;

  const MiniPruefungScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
    required this.words,
  });

  @override
  State<MiniPruefungScreen> createState() => _MiniPruefungScreenState();
}

class _MiniPruefungScreenState extends State<MiniPruefungScreen> {
  final ProgressService _p = ProgressService();

  int _i = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;

  Future<void> _check() async {
    if (_selected == null) return;

    final ok = _selected == 0;

    if (ok) {
      await _p.removeWrongWord("test");
      _correct++;
    } else {
      await _p.addWrongWord("test");
    }

    if (!mounted) return;

    setState(() {
      _checked = true;
    });
  }

  Future<void> _nextOrFinish() async {
    await _p.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: 'exam',
      xpReward: widget.xpReward,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mini Sınav Bitti'),
        content: Text('XP: ${widget.xpReward}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CoursePage(
      title: widget.title,
      subtitle: 'Mini sınav',
      leadingIcon: Icons.fact_check_rounded,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (_selected == null || _checked) ? null : _check,
                child: const Text('Kontrol Et'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: !_checked ? null : _nextOrFinish,
                child: const Text('Sınavı Bitir'),
              ),
            ),
          ],
        ),
      ),
      body: const Center(child: Text("Mini sınav ekranı aktif")),
    );
  }
}
