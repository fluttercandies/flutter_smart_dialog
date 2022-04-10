import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../config/config.dart';
import '../config/enum_config.dart';
import '../data/base_dialog.dart';

class CustomLoading extends BaseDialog {
  CustomLoading({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  Future<void> showLoading({
    required Widget widget,
    required bool clickBgDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required bool backDismiss,
  }) async {
    DialogProxy.instance.loadingBackDismiss = backDismiss;
    config.loading.isExist = true;

    return mainDialog.show(
      widget: widget,
      clickBgDismiss: clickBgDismiss,
      animationType: animationType,
      alignment: Alignment.center,
      maskColor: maskColor,
      maskWidget: maskWidget,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      onDismiss: null,
      useSystem: false,
      reuse: true,
      onBgTap: () => dismiss(),
    );
  }

  Future<T?> dismiss<T>({bool back = false}) async {
    if (!DialogProxy.instance.loadingBackDismiss && back) return null;

    await mainDialog.dismiss();
    config.loading.isExist = false;

    return null;
  }
}
