import 'package:flutter/material.dart';

import '../../config/constants.dart';

class BackgroundImage extends StatelessWidget {
  final Widget child;

  const BackgroundImage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid color fallback
        Container(color: Colors.black),

        // Background image with error handling
        Image.asset(
          webbImage,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, just use the black background
            print('Error loading background image: $error');
            return const SizedBox.shrink();
          },
        ),

        // The actual UI content
        child,
      ],
    );
  }
}
