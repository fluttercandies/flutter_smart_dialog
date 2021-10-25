import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

class ToastStrategy extends DialogAction {
  ToastStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  List<void Function()> _toastList = [];

  @override
  Future<void> showToast({
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
    required Widget widget,
  }) async {
    config.isExistToast = true;

    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.length == 0) return;

      mainAction.show(
        widget: widget,
        isPenetrate: true,
        clickBgDismiss: false,
        onBgTap: () => dismiss(),
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
