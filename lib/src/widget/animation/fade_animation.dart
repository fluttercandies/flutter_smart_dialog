import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  const FadeAnimation({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final AnimationController controller;

  final Widget child;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation> {
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _curvedAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curvedAnimation,
      child: widget.child,
    );
  }
}
