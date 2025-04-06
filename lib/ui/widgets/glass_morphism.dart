import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphism extends StatelessWidget {
  /// A widget that applies a glassmorphism effect to its child.
  const GlassMorphism({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.all(Radius.circular(32)),
          ),
          child: child,
        ),
      ),
    );
  }
}
