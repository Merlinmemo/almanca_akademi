import 'package:flutter/material.dart';

/// Column overflow problemini bitirir:
/// - Uzunsa scroll
/// - Kısaysa ekranı doldurur
class SafeScrollBody extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  const SafeScrollBody({
    super.key,
    this.padding = const EdgeInsets.all(14),
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
