import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../widgets/course_ui.dart';
import '../../theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  final String moduleCode;
  final String title;
  final String description;
  final int xpReward;

  const IntroScreen({
    super.key,
    required this.moduleCode,
    required this.title,
    required this.description,
    required this.xpReward,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final ProgressService _p = ProgressService();
  bool _done = false;

  bool get _isModul1 => widget.moduleCode == 'modul1';
  bool _ackPronouns = false;
  bool _ackSein = false;
  int? _q1;
  int? _q2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await _p.isSectionCompleted(widget.moduleCode, 'intro');
    if (!mounted) return;
    setState(() => _done = v);
  }

  bool get _quiz1Correct => _q1 == 0;
  bool get _quiz2Correct => _q2 == 1;

  bool get _canCompleteIntro {
    if (_done) return false;
    if (!_isModul1) return true;
    return _ackPronouns && _ackSein && _quiz1Correct && _quiz2Correct;
  }

  Future<void> _complete() async {
    if (_done) return;
    await _p.completeSection(moduleCode: widget.moduleCode, sectionKey: 'intro', xpReward: widget.xpReward);
    if (!mounted) return;
    setState(() => _done = true);
    Navigator.pop(context);
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(left, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5))),
          Expanded(child: Text(right, style: TextStyle(color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w700, fontSize: 15.5))),
        ],
      ),
    );
  }

  Widget _radio(int value, int? group, String label, ValueChanged<int?> onChanged) {
    final selected = value == group;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppOptionTile(
        title: label,
        selected: selected,
        onTap: () => onChanged(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CoursePage(
      title: widget.title,
      subtitle: 'Kurs hedefi ve temel kurulum',
      leadingIcon: Icons.flag_rounded,
      bottomBar: BottomActionsBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canCompleteIntro ? _complete : null,
            child: Text(_done ? 'Tamamlandı ✅' : 'Girişi Tamamla (+${widget.xpReward} XP)'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          HeroBannerCard(
            eyebrow: 'Hoş Geldin',
            title: widget.title,
            subtitle: 'Önce temel mantığı oturtuyoruz. Sonra kelime, cümle ve konuşmaya geçiyoruz.',
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.description, style: TextStyle(color: Colors.white.withOpacity(0.84), fontWeight: FontWeight.w700, fontSize: 14.5, height: 1.35)),
                const SizedBox(height: 12),
                const Text(
                  'Akış: Intro → Wortschatz → Mikro Cümle → Satzbau → Hören → Sprechen → Mini Prüfung',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
              ],
            ),
          ),
          if (_isModul1) ...[
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modül 1 • Temel yapı', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                  const SizedBox(height: 10),
                  Text(
                    'Bu modülde önce şunları oturtuyoruz:\n1) Kişi zamirleri (ich/du/er...)\n2) sein (bin/bist/ist...)\nSonra kelime → basit cümle.',
                    style: TextStyle(color: Colors.white.withOpacity(0.80), fontWeight: FontWeight.w700, fontSize: 14.5, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1) Kişi zamirleri', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 12),
                  _row('Ich', 'Ben'),
                  _row('Du', 'Sen'),
                  _row('Er', 'O (erkek)'),
                  _row('Sie', 'O (kadın)'),
                  _row('Wir', 'Biz'),
                  _row('Ihr', 'Siz'),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _ackPronouns,
                    activeColor: AppTheme.accent,
                    onChanged: (v) => setState(() => _ackPronouns = v ?? false),
                    title: const Text('Zamirleri gördüm', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                    subtitle: const Text('Ich / du / er / wir mantığı tamam.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2) sein çekimi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 12),
                  _row('Ich bin', 'Ben ...im'),
                  _row('Du bist', 'Sen ...sin'),
                  _row('Er / Sie ist', 'O ...dir'),
                  _row('Wir sind', 'Biz ...iz'),
                  _row('Ihr seid', 'Siz ...siniz'),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _ackSein,
                    activeColor: AppTheme.accent,
                    onChanged: (v) => setState(() => _ackSein = v ?? false),
                    title: const Text('sein çekimini gördüm', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                    subtitle: const Text('bin / bist / ist / sind / seid mantığı tamam.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mini kontrol', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('1) “Ben ...im” hangisi?', style: TextStyle(color: Colors.white.withOpacity(0.86), fontWeight: FontWeight.w800, fontSize: 15.5)),
                  const SizedBox(height: 12),
                  _radio(0, _q1, 'Ich bin', (v) => setState(() => _q1 = v)),
                  _radio(1, _q1, 'Du bist', (v) => setState(() => _q1 = v)),
                  _radio(2, _q1, 'Wir sind', (v) => setState(() => _q1 = v)),
                  const SizedBox(height: 8),
                  Text('2) “Sen” hangisi?', style: TextStyle(color: Colors.white.withOpacity(0.86), fontWeight: FontWeight.w800, fontSize: 15.5)),
                  const SizedBox(height: 12),
                  _radio(0, _q2, 'Ich', (v) => setState(() => _q2 = v)),
                  _radio(1, _q2, 'Du', (v) => setState(() => _q2 = v)),
                  _radio(2, _q2, 'Wir', (v) => setState(() => _q2 = v)),

                  const SizedBox(height: 12),
                  if ((_q1 != null || _q2 != null) && !_canCompleteIntro)
                    AppCard(
                      color: AppTheme.danger.withOpacity(0.10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Devam için mini kontrolü doğru çöz', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppTheme.danger)),
                          const SizedBox(height: 8),
                          Text(
                            '1. soru doğru cevap: Ich bin\n2. soru doğru cevap: Du',
                            style: TextStyle(color: Colors.white.withOpacity(0.84), fontWeight: FontWeight.w700, height: 1.35),
                          ),
                        ],
                      ),
                    ),
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
