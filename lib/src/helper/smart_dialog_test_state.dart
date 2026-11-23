import '../custom/toast/toast_tool.dart';
import '../kit/debounce_utils.dart';
import 'dialog_proxy.dart';
import 'monitor_widget_helper.dart';
import 'pop_monitor/monitor_pop_route.dart';
import 'route_record.dart';

/// Deterministic cleanup for tests that exercise process-wide singleton state.
///
/// This helper lives under `src` and is deliberately not exported by the
/// package's public library.
class SmartDialogTestState {
  SmartDialogTestState._();

  static void reset() {
    DialogProxy.instance.resetForTest();
    ToastTool.instance.resetForTest();
    DebounceUtils.instance.resetForTest();
    RouteRecord.instance.resetForTest();
    MonitorWidgetHelper.instance.resetForTest();
    MonitorPopRoute.updateOverlayBackState();
  }
}
