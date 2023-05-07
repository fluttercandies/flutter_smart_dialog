import 'package:flutter/material.dart';

class SlideAnimation extends StatefulWidget {
  const SlideAnimation({
    Key? key,
    required this.alignment,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final AlignmentGeometry alignment;

  final Widget child;

  final AnimationController controller;

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with TickerProviderStateMixin {
  late Tween<Offset> _tween;

  @override
  void initState() {
    _dealContentAnimate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SlideAnimation oldWidget) {
    if (oldWidget.child != widget.child) _dealContentAnimate();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _tween.animate(widget.controller),
      child: widget.child,
    );
  }

  ///处理下内容widget动画方向
  void _dealContentAnimate() {
    AlignmentGeometry? alignment = widget.alignment;
    var offset = const Offset(0, 0);

    if (alignment == Alignment.bottomCenter ||
        alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomRight) {
      //靠下
      offset = const Offset(0, 1);
    } else if (alignment == Alignment.topCenter ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.topRight) {
      //靠上
      offset = const Offset(0, -1);
    } else if (alignment == Alignment.centerLeft) {
      //靠左
      offset = const Offset(-1, 0);
    } else if (alignment == Alignment.centerRight) {
      //靠右
      offset = const Offset(1, 0);
    } else {
      //居中使用缩放动画,空结构体,不需要操作
    }

    _tween = Tween<Offset>(begin: offset, end: Offset.zero);
  }
}
