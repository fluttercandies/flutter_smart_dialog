import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../data/base_dialog.dart';

class CustomLoading extends BaseDialog {
  CustomLoading({required OverlayEntry overlayEntry}) : super(overlayEntry);

  Future<void> showLoading({
    required Widget widget,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required bool backDismiss,
  }) async {
    DialogProxy.instance.loadingBackDismiss = backDismiss;
    SmartDialog.config.loading.isExist = true;

    return mainDialog.show(
      widget: widget,
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
      onMask: () => clickMaskDismiss ? dismiss() : null,
    );
  }

  Future<T?> dismiss<T>({bool back = false}) async {
    if (!DialogProxy.instance.loadingBackDismiss && back) return null;

    await mainDialog.dismiss();
    SmartDialog.config.loading.isExist = false;

    return null;
  }
}
