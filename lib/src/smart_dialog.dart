import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';

import 'helper/config.dart';
import 'helper/dialog_proxy.dart';

class SmartDialog {
  /// SmartDialog global config
  ///
  /// SmartDialog全局配置
  static Config config = DialogProxy.instance.config;

  /// custom dialog
  /// attributes that use 'Temp' as the suffix will not affect the global config when used here;
  /// attributes that do not use ‘Temp' as the suffix will default to the global config
  ///
  /// 自定义dialog
  /// 使用'Temp'为后缀的属性，在此处使用，并不会影响全局的属性；未使用‘Temp’为后缀的属性，会默认使用Config设置的全局属性
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
    VoidCallback? onDismiss,
    String? tag,
    bool? backDismiss,
  }) {
    return DialogProxy.instance.show(
      widget: widget,
      alignment: alignmentTemp ?? config.alignment,
      isPenetrate: isPenetrateTemp ?? config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? config.isUseAnimation,
      animationDuration: animationDurationTemp ?? config.animationDuration,
      isLoading: isLoadingTemp ?? config.isLoading,
      maskColor: maskColorTemp ?? config.maskColor,
      maskWidget: maskWidgetTemp ?? config.maskWidget,
      clickBgDismiss: clickBgDismissTemp ?? config.clickBgDismiss,
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? true,
    );
  }

  /// provide loading dialog
  ///
  /// 提供loading弹窗
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
    bool? backDismiss,
  }) {
    return DialogProxy.instance.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismissTemp ?? false,
      isLoading: isLoadingTemp ?? true,
      maskColor: maskColorTemp ?? config.maskColor,
      maskWidget: maskWidgetTemp ?? config.maskWidget,
      isPenetrate: isPenetrateTemp ?? config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? config.isUseAnimation,
      animationDuration: animationDurationTemp ?? config.animationDuration,
      backDismiss: backDismiss ?? true,
    );
  }

  /// provide toast
  /// alignment：control the location of toast
  ///
  /// 提供toast
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
  /// other：all close
  ///
  /// tag：the dialog for setting the 'tag' can be closed
  ///
  /// 0：关闭dialog或者loading
  /// 1：仅关闭dialog
  /// 2：仅关闭toast
  /// 3：仅关闭loading
  /// other：全关闭
  ///
  /// tag：设置了tag的dialog，会被针对性关闭
  static Future<void> dismiss({int closeType = 0, String? tag}) async {
    DialogProxy.instance.dismiss(closeType: closeType, tag: tag);
  }
}
