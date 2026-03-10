import 'dart:math';
import 'package:flutter/material.dart';

class LiftedBottomBar extends StatelessWidget {
  final Widget child;

  /// ekstra yukarı taşıma (px)
  final double lift;

  const LiftedBottomBar({
    super.key,
    required this.child,
    this.lift = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Bazı cihazlarda padding.bottom 0 gelebiliyor, viewPadding daha güvenilir.
    final bottomInset = max(
      MediaQuery.of(context).viewPadding.bottom,
      MediaQuery.of(context).padding.bottom,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset + lift),
        child: child,
      ),
    );
  }
}