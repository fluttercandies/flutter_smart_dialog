import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';

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
    throw 'not implement show(...)';
  }

  /// loading
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
    throw 'not implement showLoading(...)';
  }

  /// toast
  Future<void> showToast({
    required Widget widget,
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
  }) async {
    throw 'not implement showToast(...)';
  }

  ///close dialog : must implement
  Future<void> dismiss();

  /// get Widget : must implement
  Widget getWidget() => mainAction.getWidget();
}
