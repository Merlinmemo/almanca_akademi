import 'package:flutter/material.dart';

import '../../services/content_engine/modul1_course_engine.dart';
import '../../modules/modul1/modul1_course_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

class Modul1ExamScreen extends StatefulWidget {
  final Modul1Unit unit;
  const Modul1ExamScreen({super.key, required this.unit});

  @override
  State<Modul1ExamScreen> createState() => _Modul1ExamScreenState();
}

class _Modul1ExamScreenState extends State<Modul1ExamScreen> {
  final ProgressService _p = ProgressService();
  late final List<Modul1ExamQuestion> _qs =
      Modul1CourseEngine.I.buildExamQuestions(count: 15)..shuffle();
  int _i = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;

  Modul1ExamQuestion get _q => _qs[_i];

  Future<void> _play({bool slow = false}) async {
    if (!_q.playAudio) return;
    await TtsService.I.stop();
    await TtsService.I.speakDe(_q.audioText, rate: slow ? 0.78 : 1.0);
  }

  void _check() {
    if (_selected == null) return;
    final ok = _selected == _q.correctIndex;
    setState(() {
      _checked = true;
      if (ok) _correct++;
    });
  }

  Future<void> _showDoneDialog(int pct) async {
    final comment = pct >= 85
        ? 'Taş gibi. Temeli oturtmuşsun.'
        : (pct >= 65
            ? 'İyi gidiyorsun. Bir tur tekrar yaparsan iyice oturur.'
            : 'Temel atıldı. Bir tekrar turu bu modülü çok daha sağlam kapatır.');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.accent.withOpacity(0.28)),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 22, offset: Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 32),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Modül 1 tamamlandı', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Final testi bitti. Modül 2 kilidi açılıyor.', style: TextStyle(fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ExamResultStat(label: 'Doğru', value: '$_correct')),
                    Container(width: 1, height: 46, color: Colors.white.withOpacity(0.10)),
                    Expanded(child: _ExamResultStat(label: 'Toplam', value: '${_qs.length}')),
                    Container(width: 1, height: 46, color: Colors.white.withOpacity(0.10)),
                    Expanded(child: _ExamResultStat(label: 'Başarı', value: '%$pct')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.80),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Ana akışa dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_i < _qs.length - 1) {
      setState(() {
        _i++;
        _selected = null;
        _checked = false;
      });
      return;
    }

    await _p.completeSection(
      moduleCode: 'modul1',
      sectionKey: widget.unit.key,
      xpReward: widget.unit.xpReward,
    );
    await _p.completeModule(moduleCode: 'modul1');

    if (!mounted) return;
    final pct = ((_correct / _qs.length) * 100).round();
    await _showDoneDialog(pct);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_i + 1) / _qs.length;

    return CoursePage(
      title: widget.unit.title,
      subtitle: 'Karışık final: kelime, cümle, çeviri ve dinleme',
      leadingIcon: widget.unit.icon,
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
                onPressed: !_checked ? null : _next,
                child: Text(_i == _qs.length - 1 ? 'Testi Bitir' : 'Devam'),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: 'Final Testi',
            title: 'Şimdi parçaları birleştiriyoruz',
            subtitle: 'Burada ezberi değil, anlayıp anlamadığını ölçüyoruz.',
            icon: widget.unit.icon,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('${_i + 1}/${_qs.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Soru ${_i + 1} / ${_qs.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))),
                    _ExamPill(text: 'Doğru: $_correct'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_q.promptTr, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5, color: Colors.white.withOpacity(0.78))),
                const SizedBox(height: 10),
                Text(_q.prompt, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.25)),
                if (_q.playAudio) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _play,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Normal Dinle'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _play(slow: true),
                          icon: const Icon(Icons.slow_motion_video_rounded),
                          label: const Text('Yavaş Dinle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            _q.options.length,
            (idx) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppOptionTile(
                title: _q.options[idx],
                subtitle: 'Seçenek ${String.fromCharCode(65 + idx)}',
                selected: _selected == idx,
                correct: _checked && idx == _q.correctIndex,
                wrong: _checked && _selected == idx && idx != _q.correctIndex,
                onTap: _checked ? null : () => setState(() => _selected = idx),
              ),
            ),
          ),
          if (_checked) ...[
            const SizedBox(height: 6),
            AppCard(
              color: (_selected == _q.correctIndex ? AppTheme.success : AppTheme.danger).withOpacity(0.12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == _q.correctIndex ? '✅ Güzel, final vuruşu temiz' : '❌ Burada bir tekrar daha iyi gelir',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _selected == _q.correctIndex ? AppTheme.success : AppTheme.danger,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Doğru cevap: ${_q.options[_q.correctIndex]}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, height: 1.35)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _ExamPill extends StatelessWidget {
  final String text;
  const _ExamPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 12.5)),
    );
  }
}

class _ExamResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ExamResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.70), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
