import 'package:material_ui/material_ui.dart';

import '../custom/main_dialog.dart';
import '../helper/pop_monitor/monitor_pop_route.dart';
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
    MonitorPopRoute.updateOverlayBackState();
    overlayEntry.markNeedsBuild();
  }

  void hide() {
    if (!mainDialog.visible) {
      return;
    }
    mainDialog.visible = false;
    MonitorPopRoute.updateOverlayBackState();
    overlayEntry.markNeedsBuild();
  }
}
