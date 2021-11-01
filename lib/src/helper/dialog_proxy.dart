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
    bool backDismiss = true,
  }) {
    DialogAction? action;
    var entry = OverlayEntry(
      builder: (BuildContext context) => action!.getWidget(),
    );
    action = DialogStrategy(config: config, overlayEntry: entry);
    Overlay.of(context)!.insert(entry, below: entryLoading);
    var dialogInfo = DialogInfo(action, backDismiss);
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
    bool backDismiss = true,
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
