import 'package:flutter/material.dart';

import '../config/config.dart';
import '../custom/main_dialog.dart';

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

  MainDialog mainDialog;

  /// get Widget : must implement
  Widget getWidget() => mainDialog.getWidget();
}
