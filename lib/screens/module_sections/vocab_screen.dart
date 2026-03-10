import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/word_model.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

class VocabScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final int xpReward;
  final List<WordItem> words;

  const VocabScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.xpReward,
    required this.words,
  });

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  final ProgressService _p = ProgressService();
  static const int blockSize = 20;

  late final List<WordItem> _allWords;
  int _block = 0;
  bool _done = false;
  bool _srsDone = false;

  bool get _isWrongPoolReview => widget.moduleCode == 'wrong_pool';

  int get _blockCount => (_allWords.length / blockSize).ceil();
  String get _kSrsDone => '${widget.moduleCode}_vocab_srs_done';

  List<WordItem> get _currentBlockWords {
    final start = _block * blockSize;
    final end = min(start + blockSize, _allWords.length);
    return _allWords.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _allWords = List<WordItem>.from(widget.words)..shuffle(Random());
    _loadDone();
    _loadSrsDone();
  }

  Future<void> _loadDone() async {
    if (_isWrongPoolReview) {
      if (!mounted) return;
      setState(() => _done = false);
      return;
    }
    final v = await _p.isSectionCompleted(widget.moduleCode, 'vocab');
    if (!mounted) return;
    setState(() => _done = v);
  }

  Future<void> _loadSrsDone() async {
    if (_isWrongPoolReview) {
      if (!mounted) return;
      setState(() => _srsDone = false);
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final v = sp.getBool(_kSrsDone) ?? false;
    if (!mounted) return;
    setState(() => _srsDone = v);
  }

  Future<void> _complete() async {
    if (_isWrongPoolReview) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    await _p.completeSection(
      moduleCode: widget.moduleCode,
      sectionKey: 'vocab',
      xpReward: widget.xpReward,
    );
    if (!mounted) return;
    setState(() => _done = true);
    Navigator.pop(context);
  }

  Future<void> _speak(String de) async => TtsService.I.speakDe(de);

  Future<void> _openSrs() async {
    final pool = List<WordItem>.from(_allWords);
    if (pool.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SRS için en az 4 kelime lazım.')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VocabSrsScreen(
          moduleCode: widget.moduleCode,
          words: pool,
          reviewMode: _isWrongPoolReview,
        ),
      ),
    );
    await _loadSrsDone();
  }

  @override
  Widget build(BuildContext context) {
    final lastBlock = _block == _blockCount - 1;
    final subtitle = _isWrongPoolReview
        ? 'Tekrar turu'
        : '${_allWords.length} kart';

    return CoursePage(
      title: widget.title,
      subtitle: subtitle,
      leadingIcon: _isWrongPoolReview ? Icons.refresh_rounded : Icons.style_rounded,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _block == 0
                    ? () => Navigator.pop(context)
                    : () => setState(() => _block--),
                child: Text(_block == 0 ? 'Geri Dön' : 'Önceki Blok'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _done
                    ? null
                    : () async {
                        if (!lastBlock) {
                          setState(() => _block++);
                          return;
                        }
                        if (!_srsDone || _isWrongPoolReview) {
                          await _openSrs();
                          return;
                        }
                        await _complete();
                      },
                child: Text(
                  _done
                      ? 'Tamamlandı ✅'
                      : (!lastBlock
                          ? 'Sonraki Blok'
                          : (_isWrongPoolReview
                              ? 'Tekrarı Başlat'
                              : (_srsDone ? 'Bölümü Tamamla' : 'SRS Çalış'))),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: _isWrongPoolReview ? 'Tekrar' : 'Modül',
            title: widget.title,
            subtitle: _isWrongPoolReview ? 'Tekrar edilmesi gereken kartlar' : '${_allWords.length} kart',
            icon: _isWrongPoolReview ? Icons.refresh_rounded : Icons.school_rounded,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '${_block + 1}/$_blockCount',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlerleme %${(((_block + 1) / _blockCount) * 100).round()}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.8),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: (_block + 1) / _blockCount),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                      ),
                      child: Text(
                        'Kart grubu ${_block + 1} / $_blockCount',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isWrongPoolReview
                            ? 'Tekrar modu'
                            : (_srsDone ? 'Sıralı öğrenme tamam' : 'Sıralı öğrenme'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: (_srsDone ? AppTheme.success : Colors.white.withOpacity(0.82)),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._currentBlockWords.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.de,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Okunuş: ${w.trPron}',
                            style: TextStyle(
                              fontSize: 12.8,
                              color: Colors.white.withOpacity(0.78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Türkçe: ${w.tr}',
                            style: const TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (w.group != null && w.group!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Kategori: ${w.group}',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.white.withOpacity(0.60),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (w.exampleDe != null && w.exampleDe!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              w.exampleDe!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                          ],
                          if (w.exampleTr != null && w.exampleTr!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              w.exampleTr!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.72),
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                          if (w.note != null && w.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'Not: ${w.note}',
                                style: TextStyle(
                                  fontSize: 12.8,
                                  color: Colors.white.withOpacity(0.78),
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _speak(w.de),
                      icon: const Icon(Icons.volume_up_rounded, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _VocabQ {
  final WordItem prompt;
  final List<String> optionsTr;
  final int correctIndex;
  const _VocabQ({
    required this.prompt,
    required this.optionsTr,
    required this.correctIndex,
  });
}

class _VocabSrsScreen extends StatefulWidget {
  final String moduleCode;
  final List<WordItem> words;
  final bool reviewMode;

  const _VocabSrsScreen({
    required this.moduleCode,
    required this.words,
    this.reviewMode = false,
  });

  @override
  State<_VocabSrsScreen> createState() => _VocabSrsScreenState();
}

class _VocabSrsScreenState extends State<_VocabSrsScreen> {
  final ProgressService _p = ProgressService();

  String get _kSrsDone => '${widget.moduleCode}_vocab_srs_done';
  late final List<_VocabQ> _base = _buildBase();
  late List<_VocabQ> _qs = List<_VocabQ>.from(_base);
  final List<_VocabQ> _wrongs = [];
  final Map<String, int> _wins = {};
  int _round = 0;
  int _i = 0;
  int? _selected;
  bool _checked = false;
  int _correctTotal = 0;
  int _wrongFirst = 0;
  _VocabQ get _q => _qs[_i];

  List<_VocabQ> _buildBase() {
    final rnd = Random();
    final pool = List<WordItem>.from(widget.words)..shuffle(rnd);
    final take = min(10, pool.length);
    final picked = pool.take(take).toList();

    List<String> wrongChoices(String correctTr, List<WordItem> source) {
      final unique = source
          .where((w) => w.tr != correctTr)
          .map((w) => w.tr)
          .toSet()
          .toList()
        ..shuffle(rnd);
      return unique.take(3).toList();
    }

    return picked.map((w) {
      final wrongs = wrongChoices(w.tr, pool);
      final opts = <String>[w.tr, ...wrongs]..shuffle(rnd);
      return _VocabQ(
        prompt: w,
        optionsTr: opts,
        correctIndex: opts.indexOf(w.tr),
      );
    }).toList();
  }

  bool _doneQ(_VocabQ q) => (_wins[q.prompt.de] ?? 0) >= 2;

  Future<void> _speak() async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(_q.prompt.de);
  }

  Future<void> _check() async {
    if (_selected == null) return;
    final ok = _selected == _q.correctIndex;

    if (ok) {
      _correctTotal++;
    } else if (_round == 0) {
      _wrongs.add(_q);
    }

    if (_round == 0) {
      if (ok) {
        if (widget.reviewMode) {
          await _p.postponeWrongWord(_q.prompt.de);
        }
      } else {
        await _p.addWrongWord(_q.prompt.de);
      }
    } else {
      if (ok) {
        final nextWin = (_wins[_q.prompt.de] ?? 0) + 1;
        if (nextWin >= 2) {
          if (widget.reviewMode) {
            await _p.postponeWrongWord(_q.prompt.de);
          } else {
            await _p.removeWrongWord(_q.prompt.de);
          }
        }
      } else {
        await _p.addWrongWord(_q.prompt.de);
      }
    }

    if (!mounted) return;
    setState(() {
      _checked = true;
    });
  }

  Future<void> _nextOrFinish() async {
    if (_round == 0) {
      if (_i < _qs.length - 1) {
        setState(() {
          _i++;
          _selected = null;
          _checked = false;
        });
        return;
      }

      _wrongFirst = _wrongs.length;
      if (_wrongs.isEmpty) {
        await _finish();
        return;
      }

      setState(() {
        _round = 1;
        _qs = List<_VocabQ>.from(_wrongs);
        _i = 0;
        _selected = null;
        _checked = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yanlışların: $_wrongFirst soru. Tur 2 başlıyor.'),
        ),
      );
      return;
    }

    final ok = _selected == _q.correctIndex;
    if (ok) {
      final de = _q.prompt.de;
      _wins[de] = (_wins[de] ?? 0) + 1;
      if (_doneQ(_q)) {
        _qs.removeAt(_i);
        if (_qs.isEmpty) {
          await _finish();
          return;
        }
        if (_i >= _qs.length) {
          _i = 0;
        }
      } else {
        _i = (_i + 1) % _qs.length;
      }
    } else {
      final item = _qs.removeAt(_i);
      _qs.add(item);
      if (_i >= _qs.length) {
        _i = 0;
      }
    }

    setState(() {
      _selected = null;
      _checked = false;
    });
  }

  Future<void> _finish() async {
    if (!widget.reviewMode) {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_kSrsDone, true);
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(widget.reviewMode ? 'Tekrar bitti ✅' : 'SRS bitti ✅'),
        content: Text(
          '1. Tur doğru: ${_base.length - _wrongFirst} / ${_base.length}\n'
          'Yanlış: $_wrongFirst\n'
          'Toplam doğru: $_correctTotal',
        ),
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
    final total = _qs.length;
    final progress = total == 0 ? 0.0 : ((_i + 1) / total);
    final isCorrect = _checked && (_selected == _q.correctIndex);
    final winsNow = _round == 1 ? (_wins[_q.prompt.de] ?? 0) : 0;

    return CoursePage(
      title: widget.reviewMode ? 'Zayıf Kelime Tekrarı' : 'Wortschatz SRS',
      subtitle: _round == 0
          ? (widget.reviewMode ? 'Süresi gelen tekrar turu' : 'Tur 1')
          : 'Tur 2 - tekrar',
      leadingIcon: widget.reviewMode ? Icons.refresh_rounded : Icons.quiz_rounded,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (_selected == null || _checked) ? null : () async => await _check(),
                child: const Text('Kontrol Et'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: !_checked ? null : _nextOrFinish,
                child: Text(
                  _round == 0 ? (_i == total - 1 ? 'Tur Bitir' : 'Devam') : 'Devam',
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soru ${_i + 1} / $total',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.8),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 10),
                Text(
                  _round == 0
                      ? (widget.reviewMode
                          ? 'Süresi gelen kelimeyi toparla ve doğru Türkçeyi seç.'
                          : 'Kelimeyi gör ve doğru Türkçeyi seç.')
                      : 'Tur 2: bu kelime için doğru sayısı $winsNow / 2',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _q.prompt.de,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Okunuş: ${_q.prompt.trPron}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.74),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up_rounded, size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(_q.optionsTr.length, (idx) {
            final opt = _q.optionsTr[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppOptionTile(
                title: opt,
                selected: _selected == idx,
                correct: _checked && idx == _q.correctIndex,
                wrong: _checked && _selected == idx && idx != _q.correctIndex,
                onTap: _checked ? null : () => setState(() => _selected = idx),
              ),
            );
          }),
          if (_checked) ...[
            const SizedBox(height: 6),
            Text(
              isCorrect ? '✅ Doğru' : '❌ Yanlış',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                color: isCorrect ? AppTheme.success : AppTheme.danger,
              ),
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
