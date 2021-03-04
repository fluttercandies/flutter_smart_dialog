import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';

import 'logic/config.dart';
import 'logic/smart_logic.dart';
import 'widget/toast_widget.dart';

class SmartDialog {
  ///SmartDialog相关配置,使用Config管理
  Config config;

  ///该控件是全局覆盖在app页面上的控件,该库dialog便是基于此实现;
  ///用户也可以用此控件自定义相关操作
  OverlayEntry overlayEntry;

  ///Toast之类应该是和Dialog之类区分开,且能独立存在,提供备用覆盖浮层
  OverlayEntry overlayEntryExtra;

  ///-------------------------私有类型，不对面提供修改----------------------
  ///提供全局单例
  /// 工厂模式
  factory SmartDialog() => _getInstance();

  static SmartDialog _instance;

  static SmartDialog get instance => _getInstance();

  static SmartDialog _getInstance() {
    if (_instance == null) {
      _instance = SmartDialog._internal();
    }
    return _instance;
  }

  SmartDialog._internal() {
    ///初始化一些参数
    config = SmartLogic.instance.config;
    overlayEntry = SmartLogic.instance.overlayEntry;
    overlayEntryExtra = SmartLogic.instance.overlayEntryExtra;
  }

  ///使用自定义布局
  ///
  /// 使用'Temp'为后缀的属性，在此处设置，并不会影响全局的属性，未设置‘Temp’为后缀的属性，
  /// 则默认使用Config设置的全局属性
  ///
  /// 特殊属性-isUseExtraWidget：是否使用额外覆盖浮层,可与主浮层独立开（默认：false）
  static Future<void> show({
    @required Widget widget,
    AlignmentGeometry alignmentTemp,
    bool isPenetrateTemp,
    bool isUseAnimationTemp,
    Duration animationDurationTemp,
    bool isLoadingTemp,
    Color maskColorTemp,
    bool clickBgDismissTemp,
    bool isUseExtraWidget = false,
    //overlay弹窗消失回调
    VoidCallback onDismiss,
    //额外overlay弹窗消失回调
    VoidCallback onExtraDismiss,
  }) {
    return SmartLogic.instance.show(
      widget: widget,
      alignment: alignmentTemp ?? instance.config.alignment,
      isPenetrate: isPenetrateTemp ?? instance.config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? instance.config.isUseAnimation,
      animationDuration:
          animationDurationTemp ?? instance.config.animationDuration,
      isLoading: isLoadingTemp ?? instance.config.isLoading,
      maskColor: maskColorTemp ?? instance.config.maskColor,
      clickBgDismiss: clickBgDismissTemp ?? instance.config.clickBgDismiss,
      isUseExtraWidget: isUseExtraWidget,
      onDismiss: onDismiss,
      onExtraDismiss: onExtraDismiss,
    );
  }

  ///提供loading弹窗
  static Future<void> showLoading({
    String msg = '加载中...',
    Color background = Colors.black,
    bool clickBgDismissTemp = false,
    bool isLoadingTemp = true,
    bool isPenetrateTemp,
    bool isUseAnimationTemp,
    Duration animationDurationTemp,
    Color maskColorTemp,
    bool isUseExtraWidget = false,
  }) {
    return show(
      widget: LoadingWidget(
        msg: msg,
        background: background,
      ),
      clickBgDismissTemp: clickBgDismissTemp,
      isLoadingTemp: isLoadingTemp,
      maskColorTemp: maskColorTemp,
      isPenetrateTemp: isPenetrateTemp,
      isUseAnimationTemp: isUseAnimationTemp,
      animationDurationTemp: animationDurationTemp,
      isUseExtraWidget: isUseExtraWidget,
    );
  }

  ///提供toast示例
  static Future<void> showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 1500),
    alignment: Alignment.bottomCenter,
    //默认消失类型,类似android的toast,toast一个一个展示
    //非默认消失类型,多次点击,后面toast会顶掉前者的toast显示
    bool isDefaultDismissType = true,
    Widget widget,
  }) async {

    SmartLogic.instance.showToast(
      time: time,
      isDefaultDismissType: isDefaultDismissType,
      widget: widget ?? ToastWidget(msg: msg, alignment: alignment),
    );
  }

  ///关闭Dialog
  ///
  /// closeType：关闭类型；0：仅关闭主体OverlayEntry、1：仅关闭额外OverlayEntry、2：俩者都关闭
  ///
  /// 如果不清楚使用,请查看showToast和showLoading
  static Future<void> dismiss({int closeType = 0}) async {
    return SmartLogic.dismiss(closeType: closeType);
  }
}
