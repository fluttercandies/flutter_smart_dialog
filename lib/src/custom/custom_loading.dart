import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import 'base_dialog.dart';

class CustomLoading extends BaseDialog {
  CustomLoading({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  Future<void> showLoading({
    required Widget widget,
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
    required bool backDismiss,
  }) async {
    DialogProxy.instance.loadingBackDismiss = backDismiss;
    config.isExist = true;
    config.isExistLoading = true;

    return mainDialog.show(
      widget: widget,
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      alignment: Alignment.center,
      maskColor: maskColor,
      maskWidget: maskWidget,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      onBgTap: () => dismiss(),
    );
  }

  Future<void> dismiss({bool back = false, bool pop = false}) async {
    if (!DialogProxy.instance.loadingBackDismiss && (back || pop)) return;

    await mainDialog.dismiss();

    config.isExistLoading = false;
    if (!config.isExistMain) {
      config.isExist = false;
    }
  }
}
