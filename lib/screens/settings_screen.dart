import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProgressService _progress = ProgressService();
  bool _resetting = false;

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: !_resetting,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.restart_alt_rounded, color: AppTheme.danger, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ders ilerlemesini sıfırla',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tüm modül ilerlemesi, günlük seri, XP ve son kalınan bölüm silinecek. Bu işlem geri alınamaz.',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetting ? null : () => Navigator.pop(c, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111827),
                          side: BorderSide(color: Colors.black.withOpacity(0.10)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Vazgeç', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _resetting ? null : () => Navigator.pop(c, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Sıfırla', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;

    setState(() => _resetting = true);
    await _progress.resetAllProgress();
    if (!mounted) return;
    setState(() => _resetting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('İlerleme sıfırlandı. Modül 1 baştan açıldı.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _SettingsHeaderCard(),
          const SizedBox(height: 16),
          const _SectionTitle('Öğrenme verileri'),
          const SizedBox(height: 10),
          const _ResetCardPlaceholder(),
          const SizedBox(height: 16),
          const _SectionTitle('Ses araçları'),
          const SizedBox(height: 10),
          const _TtsToolsCard(),
          const SizedBox(height: 16),
          const _SectionTitle('Yakında'),
          const SizedBox(height: 10),
          const _ComingSoonCard(),
        ],
      ),
    );
  }
}

class _SettingsHeaderCard extends StatelessWidget {
  const _SettingsHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.98),
            const Color(0xFFF3F6FA),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kontrol merkezi', style: TextStyle(color: Color(0xFF111827), fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text(
                  'Buradan ilerlemeyi yönetebilir, sıfırlayabilir ve ses araçlarını kullanabilirsin.',
                  style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.45, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
    );
  }
}

class _ResetCardPlaceholder extends StatefulWidget {
  const _ResetCardPlaceholder();

  @override
  State<_ResetCardPlaceholder> createState() => _ResetCardPlaceholderState();
}

class _ResetCardPlaceholderState extends State<_ResetCardPlaceholder> {
  bool _resetting = false;

  Future<void> _handleTap() async {
    final state = context.findAncestorStateOfType<_SettingsScreenState>();
    if (state == null || _resetting) return;
    setState(() => _resetting = true);
    await state._confirmReset();
    if (!mounted) return;
    setState(() => _resetting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.restart_alt_rounded, color: AppTheme.danger, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ders ilerlemesini sıfırla', style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text(
                        'Modüller, testler, günlük seri ve XP baştan başlar.',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _resetting
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                    : Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TtsToolsCard extends StatefulWidget {
  const _TtsToolsCard();

  @override
  State<_TtsToolsCard> createState() => _TtsToolsCardState();
}

class _TtsToolsCardState extends State<_TtsToolsCard> {
  bool _busyCache = false;
  bool _busyLimit = false;

  Future<void> _clearCache() async {
    setState(() => _busyCache = true);
    await TtsService.I.clearCache();
    if (!mounted) return;
    setState(() => _busyCache = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('TTS cache temizlendi.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _resetLimit() async {
    setState(() => _busyLimit = true);
    await TtsService.I.resetDailyLimit();
    if (!mounted) return;
    setState(() => _busyLimit = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('TTS günlük limit sayacı sıfırlandı.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _ToolRow(
              icon: Icons.cleaning_services_rounded,
              title: 'TTS cache temizle',
              subtitle: 'Eski ses dosyalarını siler. Yeni sesler yeniden üretilir.',
              busy: _busyCache,
              onTap: _busyCache ? null : _clearCache,
            ),
            const SizedBox(height: 12),
            _ToolRow(
              icon: Icons.refresh_rounded,
              title: 'TTS günlük limit sayacını sıfırla',
              subtitle: 'Günlük karakter sayacını temizler.',
              busy: _busyLimit,
              onTap: _busyLimit ? null : _resetLimit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool busy;
  final VoidCallback? onTap;

  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Color(0xFF111827), fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13.5, height: 1.4, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                  : Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ses ve öğrenme tercihleri', style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text(
                  'Yakında ses hızı, tekrar sıklığı, tema ve ders tercihleri buraya eklenecek.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
