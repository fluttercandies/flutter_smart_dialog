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
}
