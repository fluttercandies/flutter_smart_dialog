import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';

import 'dialog_strategy.dart';

class LoadingStrategy extends DialogAction {
  LoadingStrategy({
    required this.config,
    required this.overlayEntry,
  }) : _action = DialogStrategy(config: config, overlayEntry: overlayEntry);

  ///OverlayEntry instance
  final OverlayEntry overlayEntry;

  ///config info
  final Config config;

  late DialogAction _action;

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
    return _action.show(
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
    await _action.dismiss();
    config.isExist = false;
  }

  @override
  Widget getWidget() {
    return _action.getWidget();
  }
}
