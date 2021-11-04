import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

import 'main_strategy.dart';

///抽象dialog行为
abstract class DialogAction {
  DialogAction({
    required this.config,
    required this.overlayEntry,
  }) : mainAction = MainStrategy(config: config, overlayEntry: overlayEntry);

  ///OverlayEntry instance
  final OverlayEntry overlayEntry;

  ///config info
  final Config config;

  final MainStrategy mainAction;

  /// custom dialog
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
    VoidCallback? onDismiss,
  }) async {
    throw 'not implement show(...)';
  }

  /// loading
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
    throw 'not implement showLoading(...)';
  }

  /// toast
  Future<void> showToast({
    required Duration time,
    required bool antiShake,
    required Widget widget,
  }) async {
    throw 'not implement showToast(...)';
  }

  ///close dialog : must implement
  Future<void> dismiss();

  /// get Widget : must implement
  Widget getWidget() => mainAction.getWidget();
}
