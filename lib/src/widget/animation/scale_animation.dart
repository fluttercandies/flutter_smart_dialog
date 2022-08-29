import 'package:flutter/material.dart';

class ScaleAnimation extends StatelessWidget {
  const ScaleAnimation({
    Key? key,
    required this.controller,
    required this.child,
    this.alignment,
  }) : super(key: key);

  final AnimationController controller;

  final Widget child;

  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      alignment: alignment ?? Alignment(0, 0),
      scale: CurvedAnimation(parent: controller, curve: Curves.linear),
      child: child,
    );
  }
}
