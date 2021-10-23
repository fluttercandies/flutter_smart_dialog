import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';
import 'package:flutter_smart_dialog/src/strategy/dialog_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/loading_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/toast_strategy.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import 'config.dart';

class DialogProxy {
  ///SmartDialog相关配置,使用Config管理
  late Config config;

  late OverlayEntry entryMain;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;

  ///-------------------------私有类型，不对面提供修改----------------------
  late DialogAction _mainAction;
  late DialogAction _toastAction;
  late DialogAction _loadingAction;

  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  DialogProxy._internal() {
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
    var context = FlutterSmartDialog.navigatorKey.currentContext;
    print('------------------------');
    print(context?.size?.width);
    if (context != null) {
      Overlay.of(context)?.insert(entryMain);
      Overlay.of(context)?.insert(entryLoading);
      Overlay.of(context)?.insert(entryToast);
    }

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
    //overlay弹窗消失回调
    VoidCallback? onDismiss,
  }) {
    return _mainAction.show(
      widget: widget,
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
    );
  }

  ///提供loading弹窗
  Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool clickBgDismiss = false,
    bool isLoading = true,
    bool? isPenetrate,
    bool? isUseAnimation,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
    Widget? widget,
  }) {
    return _loadingAction.showLoading(
      widget: widget ?? LoadingWidget(msg: msg, background: background),
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
    );
  }

  /// 提供toast示例
  ///
  /// alignment：控制toast出现的位置
  Future<void> showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 2000),
    alignment: Alignment.bottomCenter,
    Widget? widget,
  }) async {
    _toastAction.showToast(
      time: time,
      widget: ToastHelper(
        child: widget ?? ToastWidget(msg: msg, alignment: alignment),
      ),
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
  Future<void> dismiss({int closeType = 0}) async {
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
