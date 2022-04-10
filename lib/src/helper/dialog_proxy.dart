import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/custom_loading.dart';
import 'package:flutter_smart_dialog/src/custom/custom_toast.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';

import '../config/enum_config.dart';
import '../init_dialog.dart';

class DialogProxy {
  late Config config;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;
  late Queue<DialogInfo> dialogQueue;
  late CustomToast _toast;
  late CustomLoading _loading;

  bool loadingBackDismiss = true;
  DateTime? dialogLastTime;

  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  static late BuildContext contextOverlay;
  static BuildContext? contextNavigator;

  ///set default loading widget
  late FlutterSmartLoadingBuilder loadingBuilder;

  ///set default toast widget
  late FlutterSmartToastBuilder toastBuilder;

  DialogProxy._internal() {
    config = Config();

    dialogQueue = ListQueue();
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

  Future<T?>? show<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickBgDismiss,
    required Widget? maskWidget,
    required bool debounce,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) {
    CustomDialog? dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(config: config, overlayEntry: entry);
    return dialog.show<T>(
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      debounce: debounce,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      useSystem: useSystem,
    );
  }

  Future<T?>? showAttach<T>({
    required BuildContext? targetContext,
    required Widget widget,
    required Offset? target,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickBgDismiss,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required bool debounce,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) {
    CustomDialog? dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(config: config, overlayEntry: entry);
    return dialog.showAttach<T>(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      highlightBuilder: highlightBuilder,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      debounce: debounce,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      useSystem: useSystem,
    );
  }

  Future<void> showLoading({
    required bool clickBgDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required bool backDismiss,
    required Widget widget,
  }) {
    return _loading.showLoading(
      clickBgDismiss: clickBgDismiss,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      backDismiss: backDismiss,
      widget: widget,
    );
  }

  Future<void> showToast({
    required AlignmentGeometry alignment,
    required bool clickBgDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required bool consumeEvent,
    required Duration displayTime,
    required bool debounce,
    required SmartToastType type,
    required Widget widget,
  }) async {
    return _toast.showToast(
      alignment: alignment,
      clickBgDismiss: clickBgDismiss,
      animationType: animationType,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      maskColor: maskColor,
      maskWidget: maskWidget,
      displayTime: displayTime,
      debounce: debounce,
      type: type,
      widget: ToastHelper(consumeEvent: consumeEvent, child: widget),
    );
  }

  Future<void>? dismiss<T>({
    required SmartStatus status,
    bool back = false,
    String? tag,
    T? result,
  }) {
    if (status == SmartStatus.smart) {
      var loading = config.isExistLoading;
      if (!loading)
        return CustomDialog.dismiss(DialogType.dialog, back, tag, result);
      if (loading) return _loading.dismiss(back: back);
    } else if (status == SmartStatus.toast) {
      return _toast.dismiss();
    } else if (status == SmartStatus.loading) {
      return _loading.dismiss(back: back);
    } else if (status == SmartStatus.dialog) {
      return CustomDialog.dismiss(DialogType.dialog, back, tag, result);
    } else if (status == SmartStatus.custom) {
      return CustomDialog.dismiss(DialogType.custom, back, tag, result);
    } else if (status == SmartStatus.attach) {
      return CustomDialog.dismiss(DialogType.attach, back, tag, result);
    } else if (status == SmartStatus.allDialog) {
      return CustomDialog.dismiss(DialogType.allDialog, back, tag, result);
    } else if (status == SmartStatus.allCustom) {
      return CustomDialog.dismiss(DialogType.allCustom, back, tag, result);
    } else if (status == SmartStatus.allAttach) {
      return CustomDialog.dismiss(DialogType.allAttach, back, tag, result);
    }
    return null;
  }
}
