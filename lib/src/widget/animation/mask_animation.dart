import 'package:flutter/material.dart';

class MaskAnimation extends StatefulWidget {
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
  State<MaskAnimation> createState() => _MaskAnimationState();
}

class _MaskAnimationState extends State<MaskAnimation> {
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
      child: (widget.maskWidget != null && !widget.usePenetrate)
          ? widget.maskWidget
          : Container(color: widget.usePenetrate ? null : widget.maskColor),
    );
  }
}
