import 'package:flutter/cupertino.dart';

class AttachParam {
  const AttachParam({
    required this.targetOffset,
    required this.targetSize,
    required this.selfWidget,
    required this.selfOffset,
    required this.selfSize,
  });

  final Offset targetOffset;
  final Size targetSize;

  final Widget selfWidget;
  final Offset selfOffset;
  final Size selfSize;
}

class AttachAdjustParam {
  const AttachAdjustParam({
    this.builder,
    this.alignment,
  });

  final WidgetBuilder? builder;
  final Alignment? alignment;
}
