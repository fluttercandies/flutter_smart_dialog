import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

class LoadingStrategy extends DialogAction {
  LoadingStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  @override
  Future<void> showLoading({
    required Widget widget,
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
  }) async {
    config.isExist = true;
    config.isExistLoading = true;

    return mainAction.show(
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

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();

    config.isExistLoading = false;
    if (!config.isExistMain) {
      config.isExist = false;
    }
  }
}
