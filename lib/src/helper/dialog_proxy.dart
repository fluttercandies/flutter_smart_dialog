import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/custom_loading.dart';
import 'package:flutter_smart_dialog/src/custom/custom_toast.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';

import '../smart_dialog.dart';
import 'config.dart';

class DialogProxy {
  late Config config;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;
  late Map<String, DialogInfo> dialogMap;
  late List<DialogInfo> dialogList;
  late CustomToast _toast;
  late CustomLoading _loading;

  bool loadingBackDismiss = true;
  DateTime? dialogLastTime;

  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  static late BuildContext context;

  DialogProxy._internal() {
    config = Config();

    dialogMap = {};
    dialogList = [];
  }

  void initialize() {
    entryLoading = OverlayEntry(
      builder: (BuildContext context) => _loading.getWidget(),
    );
    entryToast = OverlayEntry(
      builder: (BuildContext context) => _toast.getWidget(),
    );

    _loading = CustomLoading(config: config, overlayEntry: entryLoading);
    _toast = CustomToast(config: config, overlayEntry: entryToast);
  }

  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required Widget? maskWidget,
    required bool antiShake,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
  }) {
    CustomDialog? dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(config: config, overlayEntry: entry);
    return dialog.show(
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
      antiShake: antiShake,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
    );
  }

  Future<void> showLoading({
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
    required bool backDismiss,
    required Widget widget,
  }) {
    return _loading.showLoading(
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      backDismiss: backDismiss,
      widget: widget,
    );
  }

  Future<void> showToast({
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
    required Duration time,
    required bool antiShake,
    required SmartToastType type,
    required Widget widget,
  }) async {
    return _toast.showToast(
      clickBgDismiss: clickBgDismiss,
      isLoading: isLoading,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      maskColor: maskColor,
      maskWidget: maskWidget,
      time: time,
      antiShake: antiShake,
      type: type,
      widget: ToastHelper(child: widget),
    );
  }

  Future<void> dismiss({
    SmartStatus? status,
    String? tag,
    bool back = false,
  }) async {
    if (status == null) {
      var loading = config.isExistLoading;
      if (!loading) await CustomDialog.dismiss(tag: tag, back: back);
      if (loading) await _loading.dismiss(back: back);
    } else if (status == SmartStatus.dialog) {
      await CustomDialog.dismiss(tag: tag, back: back);
    } else if (status == SmartStatus.loading) {
      await _loading.dismiss(back: back);
    } else if (status == SmartStatus.toast) {
      await _toast.dismiss();
    } else if (status == SmartStatus.allDialog) {
      await _closeAllDialog(status: SmartStatus.dialog);
    }
  }

  Future<void> _closeAllDialog({SmartStatus? status}) async {
    var length = dialogList.length;
    for (var i = 0; i < length; i++) {
      var item = dialogList[dialogList.length - 1];

      await dismiss(status: status);
      if (item.isUseAnimation) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }
}
