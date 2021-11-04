import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

class ToastStrategy extends DialogAction {
  ToastStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  List<void Function()> _toastList = [];

  DateTime? _lastTime;

  @override
  Future<void> showToast({
    required Duration time,
    required bool antiShake,
    required Widget widget,
  }) async {
    // anti-shake
    if (antiShake) {
      var now = DateTime.now();
      var isShake = _lastTime != null &&
          now.difference(_lastTime!) < SmartDialog.config.antiShakeTime;
      _lastTime = now;
      if (isShake) return;
    }

    config.isExistToast = true;

    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.length == 0) return;

      mainAction.show(
        alignment: Alignment.center,
        maskColor: Colors.transparent,
        maskWidget: null,
        animationDuration: Duration(milliseconds: 200),
        isLoading: true,
        isUseAnimation: true,
        isPenetrate: true,
        clickBgDismiss: false,
        onBgTap: () => dismiss(),
        widget: widget,
      );
      await Future.delayed(time);
      await dismiss();

      //invoke next toast
      _toastList.removeAt(0);
      if (_toastList.length != 0) _toastList[0]();
    });

    if (_toastList.length == 1) _toastList[0]();
  }

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();

    config.isExistToast = false;
  }
}
