import 'package:flutter/material.dart';

class SizeAnimation extends StatelessWidget {
  const SizeAnimation({
    Key? key,
    required this.controller,
    required this.alignment,
    required this.child,
  }) : super(key: key);

  final AnimationController controller;

  final AlignmentGeometry alignment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: _handleAxis(),
      sizeFactor: controller,
      child: child,
    );
  }

  Axis _handleAxis() {
    var axis = Axis.vertical;

    if (alignment == Alignment.centerLeft ||
        alignment == Alignment.centerRight) {
      axis = Axis.horizontal;
    }
    return axis;
  }
}
