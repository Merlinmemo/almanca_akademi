import 'package:flutter/material.dart';

import '../../services/content_engine/modul1_course_engine.dart';
import '../../modules/modul1/modul1_course_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

class Modul1ListeningScreen extends StatefulWidget {
  final Modul1Unit unit;
  const Modul1ListeningScreen({super.key, required this.unit});

  @override
  State<Modul1ListeningScreen> createState() => _Modul1ListeningScreenState();
}

class _Modul1ListeningScreenState extends State<Modul1ListeningScreen> {
  final ProgressService _p = ProgressService();
  late final List<Modul1ListeningQuestion> _qs =
      Modul1CourseEngine.I.buildListeningQuestions(count: 12)..shuffle();
  int _i = 0;
  int? _selected;
  bool _checked = false;
  bool _played = false;
  int _correct = 0;

  Modul1ListeningQuestion get _q => _qs[_i];

  Future<void> _play({bool slow = false}) async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(
      _q.item.exampleDe ?? _q.item.de,
      rate: slow ? 0.78 : 1.0,
    );
    if (mounted) setState(() => _played = true);
  }

  void _check() {
    if (_selected == null) return;
    final ok = _selected == _q.correctIndex;
    setState(() {
      _checked = true;
      if (ok) _correct++;
    });
  }

  Future<void> _showResultDialog() async {
    final pct = ((_correct / _qs.length) * 100).round();
    await showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.accent.withOpacity(0.28)),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 22, offset: Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.headphones_rounded, color: AppTheme.success, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dinleme tamamlandı',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pct >= 80
                              ? 'Kulak alıştı. Şimdi konuşmada ağzı da açıyoruz.'
                              : 'Temel oturuyor. Bir tur daha dinlesen daha da temiz olur.',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.white.withOpacity(0.76),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ResultMiniStat(label: 'Doğru', value: '$_correct')),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.10)),
                    Expanded(child: _ResultMiniStat(label: 'Toplam', value: '${_qs.length}')),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.10)),
                    Expanded(child: _ResultMiniStat(label: 'Başarı', value: '%$pct')),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Devam'),
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
        _played = false;
      });
      return;
    }
    await _p.completeSection(
      moduleCode: 'modul1',
      sectionKey: widget.unit.key,
      xpReward: widget.unit.xpReward,
    );
    if (!mounted) return;
    await _showResultDialog();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_i + 1) / _qs.length;
    final heardText = _q.item.exampleDe ?? _q.item.de;

    return CoursePage(
      title: widget.unit.title,
      subtitle: 'Cümleyi dinle, anlamı ve kullanımı yakala',
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
                child: Text(_i == _qs.length - 1 ? 'Dinlemeyi Bitir' : 'Sonraki Soru'),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: 'Dinleme Laboratuvarı',
            title: 'Önce kulağın öğreniyor',
            subtitle: 'Cümleyi bağlam içinde dinle. Sonra anlamı yakala.',
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Soru ${_i + 1} / ${_qs.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(height: 6),
                          Text(
                            'Kategori: ${_q.item.group ?? 'Genel'}',
                            style: TextStyle(fontSize: 14.5, color: Colors.white.withOpacity(0.70), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    _TinyBadge(text: '${widget.unit.xpReward} XP'),
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
                const Text('Dinleyeceğin cümle', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                const SizedBox(height: 8),
                Text(
                  'Önce dinlemeyi dene. Yazıya sadece destek olarak bak.',
                  style: TextStyle(fontSize: 15.5, color: Colors.white.withOpacity(0.78), fontWeight: FontWeight.w700, height: 1.35),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Text(
                    heardText,
                    style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.72), fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _play,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: Text(_played ? 'Tekrar Dinle' : 'Normal Dinle'),
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
            ),
          ),
          const SizedBox(height: 14),
          const AppCard(
            child: Text(
              'Bu duyduğun cümlenin en doğru Türkçesi hangisi?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.35),
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
                    _selected == _q.correctIndex ? '✅ Güzel yakaladın' : '❌ Burada ses seni yanıltmış',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _selected == _q.correctIndex ? AppTheme.success : AppTheme.danger,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Doğru cevap: ${_q.options[_q.correctIndex]}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, height: 1.35)),
                  if ((_q.item.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'İpucu: ${_q.item.note}',
                      style: TextStyle(color: Colors.white.withOpacity(0.80), fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ],
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

class _TinyBadge extends StatelessWidget {
  final String text;
  const _TinyBadge({required this.text});

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

class _ResultMiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultMiniStat({required this.label, required this.value});

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
