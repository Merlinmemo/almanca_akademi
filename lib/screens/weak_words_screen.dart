import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';

class WeakWordsScreen extends StatefulWidget {
  const WeakWordsScreen({super.key});

  @override
  State<WeakWordsScreen> createState() => _WeakWordsScreenState();
}

class _WeakWordsScreenState extends State<WeakWordsScreen> {
  final ProgressService _progress = ProgressService();

  bool _loading = true;
  List<String> _words = const [];
  int _allPoolCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dueWords = await _progress.getDueWrongWords();
    final allWords = await _progress.getWrongWordPool();

    if (!mounted) return;
    setState(() {
      _words = dueWords;
      _allPoolCount = allWords.length;
      _loading = false;
    });
  }

  Future<void> _speak(String word) async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(word);
  }

  Future<void> _removeWord(String word) async {
    await _progress.removeWrongWord(word);
    if (!mounted) return;
    setState(() {
      _words = List<String>.from(_words)..remove(word);
      if (_allPoolCount > 0) _allPoolCount--;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('“$word” havuzdan çıkarıldı.')),
    );
  }

  Future<void> _postponeAllOneDay() async {
    if (_words.isEmpty) return;
    for (final word in _words) {
      await _progress.postponeWrongWord(word);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bugünkü weak words paketi yarına ertelendi.')),
    );
    await _load();
  }

  Future<void> _speakAllWords() async {
    if (_words.isEmpty) return;
    for (final word in _words.take(8)) {
      await _speak(word);
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  Future<void> _clearAll() async {
    if (_allPoolCount == 0) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Havuz temizlensin mi?'),
        content: const Text(
          'Tüm zayıf kelimeler listesini temizlemek üzeresin. Bu işlem geri alınmaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await _progress.clearWrongWordPool();
    if (!mounted) return;
    setState(() {
      _words = [];
      _allPoolCount = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zayıf kelime havuzu temizlendi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueCount = _words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weak Words • Zayıf Kelimeler'),
        actions: [
          IconButton(
            tooltip: 'Tümünü temizle',
            onPressed: _allPoolCount == 0 ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : dueCount == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 84,
                          width: 84,
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: AppTheme.accent,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Şu an tekrar zamanı gelen kelime yok',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _allPoolCount == 0
                              ? 'Harika. Şu an tekrar havuzunda kelime görünmüyor.\nYanlış yaptığın kelimeler burada toplanacak.'
                              : 'Havuzda $_allPoolCount kelime var ama henüz tekrar zamanı gelmemiş.\nSüresi gelince burada görünecekler.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bugünün Weak Words Paketi',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$dueCount kelime tekrar zamanı geldi. Dokun, dinle ve havuzu temizle.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.74),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_allPoolCount > dueCount) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Toplam havuz: $_allPoolCount kelime',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.56),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _WeakPill(icon: Icons.schedule_rounded, text: '$dueCount bugün'),
                        _WeakPill(icon: Icons.inventory_2_rounded, text: 'Toplam $_allPoolCount'),
                        _WeakPill(icon: Icons.refresh_rounded, text: 'SRS tekrar'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _speakAllWords,
                            icon: const Icon(Icons.volume_up_rounded, size: 18),
                            label: const Text('Toplu Dinlet'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _postponeAllOneDay,
                            icon: const Icon(Icons.event_repeat_rounded, size: 18),
                            label: const Text('Yarına Ertele'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._words.map(
                      (word) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            leading: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.spellcheck_rounded, color: AppTheme.accent),
                            ),
                            title: Text(
                              word,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            subtitle: const Text('Tekrar zamanı gelen kelime'),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  tooltip: 'Dinle',
                                  onPressed: () => _speak(word),
                                  icon: const Icon(Icons.volume_up_rounded),
                                ),
                                IconButton(
                                  tooltip: 'Havuzdan çıkar',
                                  onPressed: () => _removeWord(word),
                                  icon: const Icon(Icons.check_circle_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
    );
  }
}


class _WeakPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WeakPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
