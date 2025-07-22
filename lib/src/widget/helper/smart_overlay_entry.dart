import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

class SmartOverlayEntry extends OverlayEntry {
  SmartOverlayEntry({
    required WidgetBuilder builder,
    bool opaque = false,
    bool maintainState = false,
  }) : super(builder: builder, opaque: opaque, maintainState: maintainState);

  @override
  void markNeedsBuild() {
    ViewUtils.addSafeUse(() => super.markNeedsBuild());
  }

  @override
  void remove() {
    if (!mounted) {
      return;
    }
    super.remove();
    super.dispose();
  }
}
