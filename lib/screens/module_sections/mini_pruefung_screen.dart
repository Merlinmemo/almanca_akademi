import 'package:flutter/material.dart';

import '../../models/word_model.dart';
import '../../services/progress_service.dart';

class MiniPruefungScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final List<WordItem> words;
  final int xpReward;

  const MiniPruefungScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.words,
    required this.xpReward,
  });

  @override
  State<MiniPruefungScreen> createState() => _MiniPruefungScreenState();
}

class _MiniPruefungScreenState extends State<MiniPruefungScreen> {
  final ProgressService _progressService = ProgressService();

  int _index = 0;
  int _score = 0;
  bool _answered = false;

  List<String> _options = [];
  String _correct = '';

  WordItem get _current => widget.words[_index];

  @override
  void initState() {
    super.initState();
    if (widget.words.isNotEmpty) {
      _prepareQuestion();
    }
  }

  void _prepareQuestion() {
    final correct = _current.tr;
    final pool = widget.words.map((e) => e.tr).where((e) => e != correct).toList()
      ..shuffle();

    _options = [
      correct,
      if (pool.isNotEmpty) pool[0],
      if (pool.length > 1) pool[1],
      if (pool.length > 2) pool[2],
    ]..shuffle();

    _correct = correct;
    _answered = false;
  }

  void _choose(String value) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (value == _correct) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _next();
    });
  }

  void _next() {
    if (_index < widget.words.length - 1) {
      setState(() {
        _index++;
        _prepareQuestion();
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await _progressService.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: 'exam',
      xpReward: widget.xpReward,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sınav tamamlandı 🎓'),
        content: Text('Skorun: $_score / ${widget.words.length}'),
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
    final value = widget.words.isEmpty ? 0.0 : (_index + 1) / widget.words.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(value: value, minHeight: 10),
    );
  }

  Widget _optionButton(String text) {
    Color color = Colors.white.withOpacity(0.1);

    if (_answered) {
      if (text == _correct) {
        color = Colors.green.withOpacity(0.6);
      } else {
        color = Colors.red.withOpacity(0.35);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => _choose(text),
        child: Text(text),
      ),
    );
  }

  Widget _buildQuestionCard() {
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
          const Text(
            'Doğru anlamı seç',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _current.de,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          ..._options.map(_optionButton),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Sınav için veri bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 30),
          _buildQuestionCard(),
          const SizedBox(height: 20),
          Text(
            '${_index + 1}/${widget.words.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}