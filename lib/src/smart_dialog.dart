import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';

import 'helper/config.dart';
import 'helper/proxy.dart';

class SmartDialog {
  ///SmartDialog相关配置,使用Config管理
  Config config = DialogProxy.instance.config;

  ///-------------------------私有类型，不对面提供修改----------------------
  static SmartDialog? _instance;

  factory SmartDialog() => instance;

  static SmartDialog get instance => _instance ??= SmartDialog._internal();

  SmartDialog._internal();

  ///使用自定义布局
  ///
  /// 使用'Temp'为后缀的属性，在此处设置，并不会影响全局的属性，未设置‘Temp’为后缀的属性，
  /// 则默认使用Config设置的全局属性
  static Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignmentTemp,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    bool? isLoadingTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
    bool? clickBgDismissTemp,
    //overlay弹窗消失回调
    VoidCallback? onDismiss,
    String? tag,
  }) {
    return DialogProxy.instance.show(
      widget: widget,
      alignment: alignmentTemp ?? instance.config.alignment,
      isPenetrate: isPenetrateTemp ?? instance.config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? instance.config.isUseAnimation,
      animationDuration:
          animationDurationTemp ?? instance.config.animationDuration,
      isLoading: isLoadingTemp ?? instance.config.isLoading,
      maskColor: maskColorTemp ?? instance.config.maskColor,
      maskWidget: maskWidgetTemp ?? instance.config.maskWidget,
      clickBgDismiss: clickBgDismissTemp ?? instance.config.clickBgDismiss,
      onDismiss: onDismiss,
      tag: tag,
    );
  }

  ///提供loading弹窗
  static Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool? clickBgDismissTemp,
    bool? isLoadingTemp,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
    Widget? widget,
  }) {
    return DialogProxy.instance.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismissTemp ?? false,
      isLoading: isLoadingTemp ?? true,
      maskColor: maskColorTemp ?? instance.config.maskColor,
      maskWidget: maskWidgetTemp ?? instance.config.maskWidget,
      isPenetrate: isPenetrateTemp ?? instance.config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? instance.config.isUseAnimation,
      animationDuration:
          animationDurationTemp ?? instance.config.animationDuration,
    );
  }

  /// 提供toast示例
  ///
  /// alignment：控制toast出现的位置
  static Future<void> showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
    Widget? widget,
  }) async {
    DialogProxy.instance.showToast(
      msg,
      time: time,
      alignment: alignment,
      widget: widget,
    );
  }

  /// 0：close dialog or loading
  /// 1：only close dialog
  /// 2：only close toast
  /// 3：only close loading
  /// 4：both close
  ///
  /// tag：the dialog for setting the 'tag' can be closed
  static Future<void> dismiss({int closeType = 0,String? tag}) async {
    DialogProxy.instance.dismiss(closeType: closeType, tag: tag);
  }
}
