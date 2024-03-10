import 'package:flutter/material.dart';

class TutorialBackground extends StatelessWidget {
  const TutorialBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: child,
    );
  }
}
