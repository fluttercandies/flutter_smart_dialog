import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  const FadeAnimation({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final AnimationController controller;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
      child: child,
    );
  }
}
