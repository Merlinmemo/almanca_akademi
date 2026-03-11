import 'package:flutter/material.dart';

import '../../models/word_model.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';

class VocabScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final List<WordItem> words;
  final int xpReward;

  const VocabScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.words,
    required this.xpReward,
  });

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  final ProgressService _progressService = ProgressService();

  int _index = 0;
  bool _showMeaning = false;
  bool _completed = false;

  WordItem get _current => widget.words[_index];

  Future<void> _speak() async {
    await TtsService.I.speakDe(_current.de);
  }

  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }

  void _next() {
    if (_index < widget.words.length - 1) {
      setState(() {
        _index++;
        _showMeaning = false;
      });
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() {
        _index--;
        _showMeaning = false;
      });
    }
  }

  Future<void> _finish() async {
    if (_completed) return;

    await _progressService.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: 'vocab',
      xpReward: widget.xpReward,
    );

    setState(() {
      _completed = true;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tebrikler 🎉'),
        content: const Text('Kelime dersi tamamlandı.'),
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
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          if (_showMeaning) ...[
            Text(
              _current.tr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if ((_current.exampleDe ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _current.exampleDe!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
            if ((_current.exampleTr ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _current.exampleTr!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: _speak,
              ),
              IconButton(
                icon: Icon(
                  _showMeaning ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                ),
                onPressed: _toggleMeaning,
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
            '${_index + 1}/${widget.words.length}',
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

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Bu ders için kelime bulunamadı.')),
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
          const Spacer(),
          _buildNavigation(),
        ],
      ),
    );
  }
}