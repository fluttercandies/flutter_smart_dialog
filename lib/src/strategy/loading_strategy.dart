import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
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
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
  }) async {
    config.isExist = true;
    config.isExistLoading = true;

    return mainAction.show(
      widget: widget,
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      maskColor: maskColorTemp,
      maskWidget: maskWidgetTemp,
      isPenetrate: isPenetrateTemp,
      isUseAnimation: isUseAnimationTemp,
      animationDuration: animationDurationTemp,
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
