import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

class SmartOverlayEntry extends OverlayEntry {
  SmartOverlayEntry({required WidgetBuilder builder}) : super(builder: builder);

  @override
  void markNeedsBuild() {
    ViewUtils.addSafeUse(() => super.markNeedsBuild());
  }
}
