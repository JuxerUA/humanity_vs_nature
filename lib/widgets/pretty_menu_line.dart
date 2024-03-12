import 'package:flutter/material.dart';

class PrettyMenuLine extends StatelessWidget {
  const PrettyMenuLine({
    required this.child,
    this.color = Colors.black26,
    super.key,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 270,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
