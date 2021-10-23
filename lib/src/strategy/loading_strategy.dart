import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

class LoadingStrategy extends DialogAction {
  LoadingStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  @override
  Future<void> showLoading({
    required Widget widget,
    bool clickBgDismiss = false,
    bool isLoading = true,
    bool? isPenetrate,
    bool? isUseAnimation,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
  }) async {
    config.isExist = true;
    config.isExistLoading = true;

    return mainAction.show(
      widget: widget,
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
    );
  }

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();

    config.isExistLoading = false;
    if (!config.isExistMain) {
      config.isExist = false;
    }
  }
}
