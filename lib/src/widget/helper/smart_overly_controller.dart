part of 'smart_overlay.dart';

/// SmartOverlay Controller
class SmartOverlayController {
  VoidCallback? _onShow;
  VoidCallback? _onDismiss;

  // show
  Future<void> show() async {
    _onShow?.call();
    var completer = Completer();
    widgetsBinding.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    await completer.future;
  }

  // dismiss
  void dismiss() {
    _onDismiss?.call();
  }

  void _setListener({
    VoidCallback? onShow,
    VoidCallback? onDismiss,
  }) {
    _onShow = onShow;
    _onDismiss = onDismiss;
  }

  void _clearListener() {
    _onShow = null;
    _onDismiss = null;
  }
}
