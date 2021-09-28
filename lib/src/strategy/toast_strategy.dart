import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

class ToastStrategy extends DialogAction {
  ToastStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  List _toastList = [];

  @override
  Future<void> showToast({
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
    required Widget widget,
    bool isDefaultDismissType = true,
  }) async {
    config.isExistToast = true;

    //处理默认类型逻辑
    if (isDefaultDismissType) {
      while (true) {
        if (_toastList.length == 0) {
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    //锚定toast数量
    _toastList.add(
      mainAction.show(
        widget: widget,
        isPenetrate: true,
        clickBgDismiss: false,
      ),
    );
    await Future.delayed(time);
    //防止多个dismiss同时生效，只需要最后一个dismiss生效即可
    if (_toastList.length == 1) {
      await dismiss();
    }
    _toastList.removeLast();
  }

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();
    config.isExistToast = false;
  }
}
