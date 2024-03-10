import 'package:flutter/material.dart';

class PauseBackground extends StatelessWidget {
  const PauseBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: child,
    );
  }
}
