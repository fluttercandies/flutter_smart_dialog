import 'package:flutter/material.dart';

///抽象dialog行为
abstract class DialogAction {
  ///自定义dialog
  Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignment,
    bool? isPenetrate,
    bool? isUseAnimation,
    Duration? animationDuration,
    bool? isLoading,
    Color? maskColor,
    bool? clickBgDismiss,
    VoidCallback? onDismiss,
  }) async {}

  ///loading
  Future<void> showLoading({
    required Widget widget,
    bool clickBgDismiss = false,
    bool isLoading = true,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
  }) async {}

  ///toast
  Future<void> showToast({
    required Widget widget,
    Duration time = const Duration(milliseconds: 1500),
    alignment: Alignment.bottomCenter,
    //true：类似android的toast，toast一个一个展示
    //false：多次点击,后面toast会顶掉前者的toast显示
    bool isDefaultDismissType = true,
  }) async {}

  ///close dialog : must implement
  Future<void> dismiss();

  /// get Widget : must implement
  Widget getWidget();
}
