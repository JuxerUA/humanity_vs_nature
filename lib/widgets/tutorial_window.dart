import 'package:flutter/material.dart';

class TutorialWindow extends StatelessWidget {
  const TutorialWindow({
    required this.children,
    required this.buttons,
    this.width,
    this.height,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  final double? width;
  final double? height;
  final EdgeInsets margin;

  final List<Widget> children;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ListView(children: children)),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buttons,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
