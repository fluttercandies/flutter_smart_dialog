import 'package:flutter/material.dart';

class MaskAnimation extends StatelessWidget {
  const MaskAnimation({
    Key? key,
    required this.controller,
    required this.maskWidget,
    required this.maskColor,
    required this.usePenetrate,
  }) : super(key: key);

  final AnimationController controller;

  final Widget? maskWidget;

  final Color maskColor;

  final bool usePenetrate;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
      child: (maskWidget != null && !usePenetrate)
          ? maskWidget
          : Container(color: usePenetrate ? null : maskColor),
    );
  }
}
