import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';

import 'main_dialog.dart';

/// base dialog：encapsulate common logic
class BaseDialog {
  BaseDialog({
    required this.config,
    required this.overlayEntry,
  }) : mainDialog = MainDialog(config: config, overlayEntry: overlayEntry);

  ///OverlayEntry instance
  final OverlayEntry overlayEntry;

  ///config info
  final Config config;

  final MainDialog mainDialog;

  /// get Widget : must implement
  Widget getWidget() => mainDialog.getWidget();
}
