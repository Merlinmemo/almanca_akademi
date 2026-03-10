import 'dart:math';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF061428),
            Color(0xFF0B1E33),
            Color(0xFF1B1444),
            Color(0xFF08101F),
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _StarfieldPainter()),
          IgnorePointer(
            child: Opacity(
              opacity: 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.85, -0.6),
                    radius: 0.85,
                    colors: [
                      Color(0xFFF4C430).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.35,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.95, 0.85),
                    radius: 0.95,
                    colors: [
                      Color(0xFF8A5BFF).withOpacity(0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    Colors.black38,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(20260305);
    final w = size.width;
    final h = size.height;

    final count = (w * h / 5200).clamp(140, 420).toInt();
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * w;
      final y = rnd.nextDouble() * h;

      final a = (0.10 + rnd.nextDouble() * 0.35);
      final r = 0.4 + rnd.nextDouble() * 1.2;

      final warm = rnd.nextDouble() > 0.55;
      final c = warm ? const Color(0xFFF4C430) : const Color(0xFFB79CFF);

      paint.color = c.withOpacity(a);
      canvas.drawCircle(Offset(x, y), r, paint);

      if (rnd.nextDouble() > 0.92) {
        paint.color = c.withOpacity(a * 0.35);
        canvas.drawCircle(Offset(x, y), r * 3.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}