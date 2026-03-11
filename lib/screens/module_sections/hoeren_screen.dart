import 'package:flutter/material.dart';

import '../../models/word_model.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';

class HoerenScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;
  final List<WordItem> prompts;

  const HoerenScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
    this.prompts = const [],
  });

  @override
  State<HoerenScreen> createState() => _HoerenScreenState();
}

class _HoerenScreenState extends State<HoerenScreen> {
  final ProgressService _progressService = ProgressService();

  int _index = 0;
  bool _completed = false;
  bool _answered = false;

  List<String> _options = [];
  String _correct = '';

  List<WordItem> get _items => widget.prompts;

  WordItem get _current => _items[_index];

  @override
  void initState() {
    super.initState();
    if (_items.isNotEmpty) {
      _prepareQuestion();
    }
  }

  void _prepareQuestion() {
    final correct = _current.tr;

    final pool = _items.map((e) => e.tr).where((e) => e != correct).toList()..shuffle();

    _options = [
      correct,
      if (pool.isNotEmpty) pool[0],
      if (pool.length > 1) pool[1],
      if (pool.length > 2) pool[2],
    ]..shuffle();

    _correct = correct;
    _answered = false;
  }

  Future<void> _play() async {
    await TtsService.I.speakDe(_current.de);
  }

  void _choose(String value) {
    if (_answered) return;

    setState(() {
      _answered = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _next();
    });
  }

  void _next() {
    if (_index < _items.length - 1) {
      setState(() {
        _index++;
        _prepareQuestion();
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_completed) return;

    await _progressService.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: 'listen',
      xpReward: widget.xpReward,
    );

    setState(() {
      _completed = true;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Harika! 🎧'),
        content: const Text('Dinleme egzersizi tamamlandı.'),
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
    final value = _items.isEmpty ? 0.0 : (_index + 1) / _items.length;
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
          const Text(
            'Dinle ve doğru anlamı seç',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 36),
            onPressed: _play,
          ),
          const SizedBox(height: 20),
          ..._options.map(_optionButton),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('Bu ders için dinleme verisi bulunamadı.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 30),
          _buildCard(),
          const SizedBox(height: 20),
          Text(
            '${_index + 1}/${_items.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}