part of 'smart_overlay.dart';

/// SmartOverlay Controller
class SmartOverlayController {
  FutureVoidCallback? _onShow;
  FutureVoidCallback? _onDismiss;

  // show
  Future<void> show() async {
    if (_onShow == null) {
      return;
    }

    await _onShow?.call();
  }

  // dismiss
  Future<void> dismiss() async {
    if (_onDismiss == null) {
      return;
    }

    await _onDismiss?.call();
  }

  void _setListener({
    FutureVoidCallback? onShow,
    FutureVoidCallback? onDismiss,
  }) {
    _onShow = onShow;
    _onDismiss = onDismiss;
  }

  void _clearListener() {
    _onShow = null;
    _onDismiss = null;
  }
}
