import 'package:flutter/material.dart';

/// Custom widget for the Card Swipes
class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(color),
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
