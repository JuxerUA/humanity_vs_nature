import 'package:flutter/material.dart';

class PrettyMenuLine extends StatelessWidget {
  const PrettyMenuLine({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 270,
        color: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
