import 'package:flutter/material.dart';

import '../../models/word_model.dart';
import '../../modules/modul1/modul1_course_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';

class Modul1UnitLessonScreen extends StatefulWidget {
  final Modul1Unit unit;

  const Modul1UnitLessonScreen({
    super.key,
    required this.unit,
  });

  @override
  State<Modul1UnitLessonScreen> createState() => _Modul1UnitLessonScreenState();
}

class _Modul1UnitLessonScreenState extends State<Modul1UnitLessonScreen> {
  final ProgressService _progressService = ProgressService();

  int _index = 0;
  bool _completed = false;

  List<WordItem> get _words => widget.unit.entries.map((e) => e.toWordItem()).toList();

  WordItem get _current => _words[_index];

  Future<void> _speakWord() async {
    await TtsService.I.speakDe(_current.de);
  }

  Future<void> _speakSentence() async {
    final text = _current.exampleDe;
    if (text != null && text.trim().isNotEmpty) {
      await TtsService.I.speakDe(text);
    }
  }

  void _next() {
    if (_index < _words.length - 1) {
      setState(() {
        _index++;
      });
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() {
        _index--;
      });
    }
  }

  Future<void> _finish() async {
    if (_completed) return;

    await _progressService.completeSection(
      moduleCode: 'modul1',
      sectionKey: widget.unit.key,
      xpReward: widget.unit.xpReward,
    );

    setState(() {
      _completed = true;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Harika! 🎉'),
          content: const Text('Bu dersi tamamladın.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                Navigator.pop(context);
              },
              child: const Text('Devam'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          Text(
            _current.de,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _current.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if ((_current.exampleDe ?? '').isNotEmpty)
            Text(
              _current.exampleDe!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          const SizedBox(height: 10),
          if ((_current.exampleTr ?? '').isNotEmpty)
            Text(
              _current.exampleTr!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: _speakWord,
              ),
              if ((_current.exampleDe ?? '').isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.record_voice_over_rounded),
                  onPressed: _speakSentence,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _prev,
            child: const Text('Geri'),
          ),
          const Spacer(),
          Text(
            '${_index + 1}/${_words.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _next,
            child: const Text('İleri'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final value = _words.isEmpty ? 0.0 : (_index + 1) / _words.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.unit.title),
        ),
        body: const Center(
          child: Text('Bu derste içerik bulunamadı.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 30),
          _buildCard(),
          const Spacer(),
          _buildNavigation(),
        ],
      ),
    );
  }
}