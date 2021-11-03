import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';
import 'package:flutter_smart_dialog/src/strategy/dialog_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/loading_strategy.dart';
import 'package:flutter_smart_dialog/src/strategy/toast_strategy.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import '../smart_dialog.dart';
import 'config.dart';
import 'entity.dart';

class DialogProxy {
  late Config config;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;
  late Map<String, DialogInfo> dialogMap;
  late List<DialogInfo> dialogList;
  late DialogAction _toastAction;
  late DialogAction _loadingAction;
  bool _loadingBackDismiss = true;

  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  static late BuildContext context;

  DialogProxy._internal() {
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

  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required Widget? maskWidget,
    required bool clickBgDismiss,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
  }) {
    DialogAction? action;
    var entry = OverlayEntry(
      builder: (BuildContext context) => action!.getWidget(),
    );
    action = DialogStrategy(config: config, overlayEntry: entry);
    Overlay.of(context)!.insert(entry, below: entryLoading);
    var dialogInfo = DialogInfo(action, backDismiss, isUseAnimation);
    dialogList.add(dialogInfo);
    if (tag != null) dialogMap[tag] = dialogInfo;

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
      onBgTap: () => dismiss(status: SmartStatus.dialog),
    );
  }

  Future<void> showLoading({
    required String msg,
    required Color background,
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
    required Widget? widget,
    required bool backDismiss,
  }) {
    _loadingBackDismiss = backDismiss;
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

  Future<void> showToast(
    String msg, {
    required Duration time,
    required AlignmentGeometry alignment,
    required Widget? widget,
  }) async {
    _toastAction.showToast(
      time: time,
      widget: ToastHelper(
        child: widget ?? ToastWidget(msg: msg, alignment: alignment),
      ),
    );
  }

  Future<void> dismiss({
    SmartStatus? status,
    String? tag,
    bool back = false,
    bool pop = false,
  }) async {
    if (status == null) {
      if (!config.isExistLoading) await _closeMain(tag, back, pop);
      if (config.isExistLoading) await _closeLoading(back, pop);
    } else if (status == SmartStatus.dialog) {
      await _closeMain(tag, back, pop);
    } else if (status == SmartStatus.loading) {
      await _closeLoading(back, pop);
    } else if (status == SmartStatus.toast) {
      await _toastAction.dismiss();
    } else if (status == SmartStatus.allDialog) {
      await closeAllDialog(status: SmartStatus.dialog);
    }
  }

  Future<void> closeAllDialog({
    SmartStatus? status,
    bool pop = false,
  }) async {
    var length = dialogList.length;
    for (var i = 0; i < length; i++) {
      var item = dialogList[dialogList.length - 1];

      await dismiss(pop: pop, status: status);
      if (item.isUseAnimation) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }

  Future<void> _closeLoading(bool back, bool pop) async {
    if (!_loadingBackDismiss && (back || pop)) return;
    await _loadingAction.dismiss();
  }

  Future<void> _closeMain(String? tag, bool back, bool pop) async {
    var length = dialogList.length;
    if (length == 0) return;

    var info = (tag == null ? dialogList[length - 1] : dialogMap[tag]);
    if (info == null || (!info.backDismiss && (back || pop))) return;

    //handle close dialog
    if (tag != null) dialogMap.remove(tag);
    dialogList.remove(info);
    DialogAction action = info.action;
    await action.dismiss();
    action.overlayEntry.remove();
  }
}
