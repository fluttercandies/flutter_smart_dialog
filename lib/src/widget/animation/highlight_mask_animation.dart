import 'package:flutter/material.dart';

import '../attach_dialog_widget.dart';

class HighlightMaskAnimation extends StatelessWidget {
  const HighlightMaskAnimation({
    Key? key,
    required this.controller,
    required this.maskWidget,
    required this.maskColor,
    required this.usePenetrate,
    required this.targetOffset,
    required this.targetSize,
    required this.highlightBuilder,
  }) : super(key: key);

  final AnimationController controller;

  final Widget? maskWidget;

  final Color maskColor;

  final bool usePenetrate;

  final Offset targetOffset;
  final Size targetSize;

  final HighlightBuilder highlightBuilder;

  @override
  Widget build(BuildContext context) {
    //handle mask
    late Widget mask;
    if (usePenetrate) {
      mask = Container();
    } else if (maskWidget != null) {
      mask = maskWidget!;
    } else {
      mask = ColorFiltered(
        colorFilter: ColorFilter.mode(
          // mask color
          maskColor,
          BlendMode.srcOut,
        ),
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              // any color
              color: Colors.white,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),

          //dissolve mask, highlight location
          highlightBuilder(targetOffset, targetSize)
        ]),
      );
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
      child: mask,
    );
  }
}
