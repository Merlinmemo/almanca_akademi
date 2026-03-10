import 'dart:math';
import 'package:flutter/material.dart';

import '../../modules/modul1/modul1_course_data.dart';
import '../../services/content_engine/modul1_course_engine.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_ui.dart';

class Modul1SpeakingScreen extends StatefulWidget {
  final Modul1Unit unit;
  const Modul1SpeakingScreen({super.key, required this.unit});

  @override
  State<Modul1SpeakingScreen> createState() => _Modul1SpeakingScreenState();
}

class _Modul1SpeakingScreenState extends State<Modul1SpeakingScreen> {
  final ProgressService _p = ProgressService();
  late final List<Modul1SpeakingPrompt> _prompts =
      (Modul1CourseEngine.I.buildSpeakingPrompts(count: 12)..shuffle(Random()));
  int _i = 0;
  bool _showHint = false;
  bool _showPersonalTask = false;

  Modul1SpeakingPrompt get _prompt => _prompts[_i];

  Future<void> _play({bool slow = false}) async {
    await TtsService.I.stop();
    await TtsService.I.speakDe(_prompt.de, rate: slow ? 0.78 : 1.0);
  }

  Future<void> _showDoneDialog() async {
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
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 22, offset: Offset(0, 12))],
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
                      color: AppTheme.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.mic_rounded, color: AppTheme.accent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Konuşma tamamlandı', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          'Şimdi kelimeyi sadece görmüyorsun, ağzından da çıkarıyorsun.',
                          style: TextStyle(fontSize: 14.5, color: Colors.white.withOpacity(0.76), fontWeight: FontWeight.w600, height: 1.35),
                        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bu bölümde ne kazandın?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    SizedBox(height: 10),
                    _DonePoint(text: 'Kalıbı sesle taklit ettin'),
                    _DonePoint(text: 'Temel vurgu ve ritmi çalıştın'),
                    _DonePoint(text: 'Cümleyi kendine göre değiştirmeyi denedin'),
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
    if (_i < _prompts.length - 1) {
      setState(() {
        _i++;
        _showHint = false;
        _showPersonalTask = false;
      });
      return;
    }
    await _p.completeSection(
      moduleCode: 'modul1',
      sectionKey: widget.unit.key,
      xpReward: widget.unit.xpReward,
    );
    if (!mounted) return;
    await _showDoneDialog();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_i + 1) / _prompts.length;

    return CoursePage(
      title: widget.unit.title,
      subtitle: 'Dinle → tekrar et → değiştir → kendi cümleni üret',
      leadingIcon: widget.unit.icon,
      bottomBar: BottomActionsBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _i == 0
                    ? null
                    : () => setState(() {
                          _i--;
                          _showHint = false;
                          _showPersonalTask = false;
                        }),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Önceki'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _next,
                icon: Icon(_i == _prompts.length - 1 ? Icons.verified_rounded : Icons.arrow_forward_rounded),
                label: Text(_i == _prompts.length - 1 ? 'Konuşmayı Bitir' : 'Sonraki Konuşma'),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: 'Konuşma Drili',
            title: _prompt.title,
            subtitle: _prompt.instruction,
            icon: widget.unit.icon,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('${_i + 1}/${_prompts.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Konuşma akışı', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))),
                    _SpeakingBadge(text: '${widget.unit.xpReward} XP'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _FlowStep(number: '1', title: 'Dinle')),
                    SizedBox(width: 8),
                    Expanded(child: _FlowStep(number: '2', title: 'Tekrar Et')),
                    SizedBox(width: 8),
                    Expanded(child: _FlowStep(number: '3', title: 'Değiştir')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dinleyeceğin örnek', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                const SizedBox(height: 10),
                Text(_prompt.de, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.25)),
                const SizedBox(height: 8),
                Text(
                  _prompt.tr,
                  style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.78), fontWeight: FontWeight.w700, height: 1.35),
                ),
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
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Nasıl çalış?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                SizedBox(height: 12),
                _HowToRow(index: '1', text: 'Önce sesi dinle ve ritmi kulağına yerleştir'),
                SizedBox(height: 10),
                _HowToRow(index: '2', text: 'Metne bakarak yavaşça tekrar et'),
                SizedBox(height: 10),
                _HowToRow(index: '3', text: 'Sonra metne bakmadan tekrar dene'),
                SizedBox(height: 10),
                _HowToRow(index: '4', text: '1-2 kelime değiştir ve cümleyi kendine ait yap'),
                SizedBox(height: 10),
                _HowToRow(index: '5', text: 'Vurguyu ve ritmi taklit et'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Konuşma ipucu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                const SizedBox(height: 8),
                Text(
                  _prompt.tip,
                  style: TextStyle(fontSize: 17, color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700, height: 1.35),
                ),
                const SizedBox(height: 14),
                if (_showHint)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text(
                      'Bu kalıbın iskeleti şudur: önce özne, sonra fiil, sonra bilgi. Kendi adını, şehrini, yaşını ya da gününü koy. Cümleyi senden bir cümleye çevir.',
                      style: TextStyle(fontSize: 16.5, color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700, height: 1.4),
                    ),
                  ),
                if (_showPersonalTask) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.18)),
                    ),
                    child: Text(
                      'Şimdi görev şu: bu cümlede en az 2 şeyi kendine göre değiştir. Örneğin adını, yaşadığın yeri, çalıştığın yeri ya da konuştuğun dili değiştir.',
                      style: TextStyle(fontSize: 16.5, color: Colors.white.withOpacity(0.86), fontWeight: FontWeight.w800, height: 1.4),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showHint = !_showHint),
                        icon: const Icon(Icons.lightbulb_rounded),
                        label: Text(_showHint ? 'İpucunu Gizle' : 'İpucu Aç'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showPersonalTask = !_showPersonalTask),
                        icon: const Icon(Icons.edit_rounded),
                        label: Text(_showPersonalTask ? 'Görevi Gizle' : 'Kendine Uyarla'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String number;
  final String title;
  const _FlowStep({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.14), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent)),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _HowToRow extends StatelessWidget {
  final String index;
  final String text;
  const _HowToRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          height: 24,
          width: 24,
          decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(index, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.84), height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _SpeakingBadge extends StatelessWidget {
  final String text;
  const _SpeakingBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 12.5)),
    );
  }
}

class _DonePoint extends StatelessWidget {
  final String text;
  const _DonePoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15.5, color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
