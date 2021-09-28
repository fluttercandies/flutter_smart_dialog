import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

///main function : customize dialog
class DialogStrategy extends DialogAction {
  DialogStrategy({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  @override
  Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignment,
    bool? isPenetrate,
    bool? isUseAnimation,
    Duration? animationDuration,
    bool? isLoading,
    Color? maskColor,
    Widget? maskWidget,
    bool? clickBgDismiss,
    VoidCallback? onDismiss,
  }) async {
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
    );
  }

  @override
  Future<void> dismiss() async {
    await mainAction.dismiss();

    config.isExistMain = false;
    if (!config.isExistLoading) {
      config.isExist = false;
    }
  }
}
