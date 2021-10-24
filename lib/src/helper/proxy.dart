import 'package:flutter/material.dart';
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

  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;

  static late BuildContext context;

  ///-------------------------私有类型，不对面提供修改----------------------
  late DialogAction _toastAction;
  late DialogAction _loadingAction;
  late Map<String, DialogAction> dialogMap;
  late List<DialogAction> dialogList;

  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  DialogProxy._internal() {
    ///init some param
    config = Config();

    entryLoading = OverlayEntry(
      builder: (BuildContext context) => _loadingAction.getWidget(),
    );
    entryToast = OverlayEntry(
      builder: (BuildContext context) => _toastAction.getWidget(),
    );

    _loadingAction = LoadingStrategy(
      config: config,
      overlayEntry: entryLoading,
    );
    _toastAction = ToastStrategy(config: config, overlayEntry: entryToast);

    dialogMap = {};
    dialogList = [];
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
    VoidCallback? onDismiss,
    String? tag,
  }) {
    DialogAction? action;
    var entry = OverlayEntry(
      builder: (BuildContext context) => action!.getWidget(),
    );
    action = DialogStrategy(config: config, overlayEntry: entry);
    Overlay.of(context)!.insert(entry, below: entryLoading);
    dialogList.add(action);
    if (tag != null) dialogMap[tag] = action;

    return action.show(
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

  /// 0：close dialog or loading
  /// 1：only close dialog
  /// 2：only close toast
  /// 3：only close loading
  /// 4：both close
  ///
  /// tag：the dialog for setting the 'tag' can be closed
  Future<void> dismiss({int closeType = 0, String? tag}) async {
    if (closeType == 0) {
      if (config.isExistLoading) await _loadingAction.dismiss();
      if (!config.isExistLoading) await _closeMain(tag);
    } else if (closeType == 1) {
      await _closeMain(tag);
    } else if (closeType == 2) {
      await _toastAction.dismiss();
    } else if (closeType == 3) {
      await _loadingAction.dismiss();
    } else {
      await _closeMain(tag);
      await _toastAction.dismiss();
      await _loadingAction.dismiss();
    }
  }

  Future<void> _closeMain(String? tag) async {
    if (dialogList.length == 0) return;

    DialogAction? action;
    if (tag == null) {
      action = dialogList[dialogList.length - 1];
    } else {
      action = dialogMap[tag];
      dialogMap.remove(tag);
    }
    await action?.dismiss();
    action?.overlayEntry.remove();
    dialogList.remove(action);
  }
}
