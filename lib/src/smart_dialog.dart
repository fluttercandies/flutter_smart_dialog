import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/strategy/dialog_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/toast_strategy.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';

import 'config/config.dart';
import 'strategy/action.dart';
import 'strategy/loading_strategy.dart';
import 'widget/toast_widget.dart';

class SmartDialog {
  ///SmartDialog相关配置,使用Config管理
  late Config config;

  late OverlayEntry entryMain;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;

  ///-------------------------私有类型，不对面提供修改----------------------
  static late DialogAction _mainAction;
  static late DialogAction _toastAction;
  static late DialogAction _loadingAction;
  static SmartDialog? _instance;

  factory SmartDialog() => instance;

  static SmartDialog get instance => _instance ??= SmartDialog._internal();

  SmartDialog._internal() {
    ///初始化一些参数
    config = Config();

    entryMain = OverlayEntry(
      builder: (BuildContext context) {
        return _mainAction.getWidget();
      },
    );
    entryLoading = OverlayEntry(
      builder: (BuildContext context) {
        return _loadingAction.getWidget();
      },
    );
    entryToast = OverlayEntry(
      builder: (BuildContext context) {
        return _toastAction.getWidget();
      },
    );

    _mainAction = DialogStrategy(config: config, overlayEntry: entryMain);
    _loadingAction = LoadingStrategy(
      config: config,
      overlayEntry: entryLoading,
    );
    _toastAction = ToastStrategy(config: config, overlayEntry: entryToast);
  }

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
  }) {
    return _mainAction.show(
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
    );
  }

  ///提供loading弹窗
  static Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool clickBgDismissTemp = false,
    bool isLoadingTemp = true,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
    Widget? widget,
  }) {
    return _loadingAction.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismissTemp,
      isLoading: isLoadingTemp,
      maskColorTemp: maskColorTemp,
      maskWidgetTemp: maskWidgetTemp,
      isPenetrateTemp: isPenetrateTemp,
      isUseAnimationTemp: isUseAnimationTemp,
      animationDurationTemp: animationDurationTemp,
    );
  }

  /// 提供toast示例
  ///
  /// isDefaultDismissType  true：toast一个个显示  false：后面toast会顶掉前面toast
  ///
  /// alignment：控制toast出现的位置
  static Future<void> showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
    bool isDefaultDismissType = true,
    Widget? widget,
  }) async {
    _toastAction.showToast(
      time: time,
      isDefaultDismissType: isDefaultDismissType,
      widget: widget ?? ToastWidget(msg: msg, alignment: alignment),
    );
  }

  ///关闭Dialog
  ///
  /// closeType：关闭类型
  ///
  /// 0：关闭主体OverlayEntry和loading
  /// 1：仅关闭主体OverlayEntry
  /// 2：仅关闭Toast
  /// 3：仅关闭loading
  /// 4：都关闭
  static Future<void> dismiss({int closeType = 0}) async {
    if (closeType == 0) {
      await _mainAction.dismiss();
      await _loadingAction.dismiss();
    } else if (closeType == 1) {
      await _mainAction.dismiss();
    } else if (closeType == 2) {
      await _toastAction.dismiss();
    } else if (closeType == 3) {
      await _loadingAction.dismiss();
    } else {
      await _mainAction.dismiss();
      await _toastAction.dismiss();
      await _loadingAction.dismiss();
    }
  }
}
