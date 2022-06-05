part of 'dialog_scope.dart';

/// SmartDialog Controller
class SmartDialogController {
  VoidCallback? _callback;

  /// refresh dialog
  ///
  /// 刷新dialog
  void refresh() {
    _callback?.call();
  }

  void _setListener(VoidCallback? voidCallback) {
    _callback = voidCallback;
  }

  void _dismiss() {
    _callback = null;
  }
}
