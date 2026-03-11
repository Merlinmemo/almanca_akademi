import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../services/tts_service.dart';

class SprechenScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;

  const SprechenScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
  });

  @override
  State<SprechenScreen> createState() => _SprechenScreenState();
}

class _SprechenScreenState extends State<SprechenScreen> {
  final ProgressService _progressService = ProgressService();

  final List<String> _sentences = const [
    'Guten Morgen',
    'Wie geht es dir?',
    'Ich arbeite heute',
    'Ich lerne Deutsch',
    'Ich bin bereit',
  ];

  int _index = 0;
  bool _completed = false;

  String get _current => _sentences[_index];

  Future<void> _speak() async {
    await TtsService.I.speakDe(_current);
  }

  void _next() {
    if (_index < _sentences.length - 1) {
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
      moduleCode: widget.moduleCode,
      sectionKey: 'speak',
      xpReward: widget.xpReward,
    );

    setState(() {
      _completed = true;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Harika! 🎤'),
        content: const Text('Konuşma egzersizi tamamlandı.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final value = (_index + 1) / _sentences.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(value: value, minHeight: 10),
    );
  }

  Widget _buildSentenceCard() {
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
            _current,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 32),
            onPressed: _speak,
          ),
          const SizedBox(height: 10),
          const Text(
            'Cümleyi yüksek sesle tekrar et',
            style: TextStyle(fontSize: 16),
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
          ElevatedButton(onPressed: _prev, child: const Text('Geri')),
          const Spacer(),
          Text(
            '${_index + 1}/${_sentences.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(onPressed: _next, child: const Text('İleri')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 30),
          _buildSentenceCard(),
          const Spacer(),
          _buildNavigation(),
        ],
      ),
    );
  }
}