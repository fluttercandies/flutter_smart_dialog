import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../attach_dialog_widget.dart';

class HighlightMaskAnimation extends StatefulWidget {
  const HighlightMaskAnimation({
    Key? key,
    required this.controller,
    required this.maskWidget,
    required this.maskColor,
    required this.usePenetrate,
    required this.targetOffset,
    required this.targetSize,
    required this.highlightBuilder,
    required this.nonAnimationTypes,
  }) : super(key: key);

  final AnimationController controller;

  final Widget? maskWidget;

  final Color maskColor;

  final bool usePenetrate;

  final Offset targetOffset;
  final Size targetSize;

  final HighlightBuilder? highlightBuilder;

  final List<SmartNonAnimationType> nonAnimationTypes;

  @override
  State<HighlightMaskAnimation> createState() => _HighlightMaskAnimationState();
}

class _HighlightMaskAnimationState extends State<HighlightMaskAnimation> {
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
    //handle mask
    late Widget mask;
    if (widget.usePenetrate) {
      mask = Container();
    } else if (widget.maskWidget != null) {
      mask = widget.maskWidget!;
    } else if (widget.highlightBuilder == null) {
      mask = Container(color: widget.maskColor);
    } else {
      mask = ColorFiltered(
        colorFilter: ColorFilter.mode(
          // mask color
          widget.maskColor,
          BlendMode.srcOut,
        ),
        child: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              // any color
              color: Colors.white,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),

          //dissolve mask, highlight location
          widget.highlightBuilder!.call(widget.targetOffset, widget.targetSize)
        ]),
      );
    }

    Widget maskAnimation = FadeTransition(
      opacity: _curvedAnimation,
      child: mask,
    );
    if (widget.highlightBuilder != null) {
      for (var element in widget.nonAnimationTypes) {
        if (element == SmartNonAnimationType.highlightMask_nonAnimation) {
          maskAnimation = mask;
        }
      }
    }

    return maskAnimation;
  }
}
