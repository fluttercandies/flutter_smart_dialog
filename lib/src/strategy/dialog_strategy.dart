import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

import '../../flutter_smart_dialog.dart';

///main function : custom dialog
class DialogStrategy extends DialogAction {
  DialogStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  DateTime? _lastTime;

  @override
  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required SmartDialogVoidCallBack onBgTap,
    required bool antiShake,
    required Widget? maskWidget,
    required bool backDismiss,
    VoidCallback? onDismiss,
  }) async {
    // anti-shake
    if (antiShake) {
      var now = DateTime.now();
      var isShake = _lastTime != null &&
          now.difference(_lastTime!) < SmartDialog.config.antiShakeTime;
      _lastTime = now;
      if (isShake) return;
    }




    config.isExist = true;
    config.isExistMain = true;

    return mainAction.show(
      widget: widget,
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      onBgTap: () => onBgTap,
    );
  }

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();
    if (DialogProxy.instance.dialogList.length != 0) return;

    config.isExistMain = false;
    if (!config.isExistLoading) {
      config.isExist = false;
    }
  }
}
