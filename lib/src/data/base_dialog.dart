import 'package:flutter/material.dart';

import '../custom/main_dialog.dart';
import '../widget/helper/smart_overlay_entry.dart';

/// base dialog：encapsulate common logic
class BaseDialog {
  BaseDialog(this.overlayEntry)
      : mainDialog = MainDialog(overlayEntry: overlayEntry);

  ///OverlayEntry instance
  final SmartOverlayEntry overlayEntry;

  MainDialog mainDialog;

  /// get Widget : must implement
  Widget getWidget() => mainDialog.getWidget();

  void appear() {
    if (mainDialog.visible) {
      return;
    }

    mainDialog.visible = true;
    overlayEntry.markNeedsBuild();
  }

  void hide() {
    if (!mainDialog.visible) {
      return;
    }
    mainDialog.visible = false;
    overlayEntry.markNeedsBuild();
  }
}
