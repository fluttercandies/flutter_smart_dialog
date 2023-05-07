import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

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
  Widget build(BuildContext context) {
    //handle mask
    late Widget mask;
    if (usePenetrate) {
      mask = Container();
    } else if (maskWidget != null) {
      mask = maskWidget!;
    } else if (highlightBuilder == null) {
      mask = Container(color: maskColor);
    } else {
      mask = ColorFiltered(
        colorFilter: ColorFilter.mode(
          // mask color
          maskColor,
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
          highlightBuilder!.call(targetOffset, targetSize)
        ]),
      );
    }

    Widget maskAnimation = FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
      child: mask,
    );
    if (highlightBuilder != null) {
      for (var element in nonAnimationTypes) {
        if (element == SmartNonAnimationType.highlightMask_nonAnimation) {
          maskAnimation = mask;
        }
      }
    }

    return maskAnimation;
  }
}
