import 'dart:math';
import 'package:flutter/material.dart';

class DockedActions extends StatelessWidget {
  final Widget child;

  /// butonları ekstra yukarı kaldırma (px)
  final double extraLift;

  /// yan padding
  final double side;

  const DockedActions({
    super.key,
    required this.child,
    this.extraLift = 18,
    this.side = 14,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = max(
      MediaQuery.of(context).viewPadding.bottom,
      MediaQuery.of(context).padding.bottom,
    );

    // Asıl sihir: Positioned.bottom burada kullanılacak.
    // Bu widget sadece padding/çerçeve standardı veriyor.
    return Padding(
      padding: EdgeInsets.fromLTRB(side, 0, side, bottomInset + extraLift),
      child: child,
    );
  }

  /// Body içine Stack ile yerleştirmek için bottom offset verir
  static double bottomOffset(BuildContext context, {double extraLift = 18}) {
    final bottomInset = max(
      MediaQuery.of(context).viewPadding.bottom,
      MediaQuery.of(context).padding.bottom,
    );
    return bottomInset + extraLift;
  }
}