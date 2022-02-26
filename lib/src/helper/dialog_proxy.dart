import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/custom_loading.dart';
import 'package:flutter_smart_dialog/src/custom/custom_toast.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_helper.dart';

import '../dialog.dart';
import '../smart_dialog.dart';
import 'config.dart';

class DialogProxy {
  late Config config;
  late OverlayEntry entryToast;
  late OverlayEntry entryLoading;
  late Map<String, DialogInfo> dialogMap;
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

    dialogMap = {};
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
      debounce: debounce,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      useSystem: useSystem,
    );
  }

  Future<void> showAttach({
    required BuildContext? targetContext,
    required Widget widget,
    required Offset? target,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required Widget? maskWidget,
    required Positioned highlight,
    required HighlightBuilder? highlightBuilder,
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
    return dialog.showAttach(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      highlight: highlight,
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
    required bool debounce,
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
      debounce: debounce,
      type: type,
      widget: ToastHelper(child: widget),
    );
  }

  Future<void> dismiss({
    required SmartStatus status,
    String? tag,
    bool back = false,
  }) async {
    if (status == SmartStatus.smart) {
      var loading = config.isExistLoading;
      if (!loading) await CustomDialog.dismiss(tag: tag, back: back);
      if (loading) await _loading.dismiss(back: back);
    } else if (status == SmartStatus.toast) {
      await _toast.dismiss();
    } else if (status == SmartStatus.loading) {
      await _loading.dismiss(back: back);
    } else if (status == SmartStatus.dialog) {
      await CustomDialog.dismiss(tag: tag, back: back);
    } else if (status == SmartStatus.custom) {
      await CustomDialog.dismiss(type: DialogType.custom, tag: tag);
    } else if (status == SmartStatus.attach) {
      await CustomDialog.dismiss(type: DialogType.attach, tag: tag);
    } else if (status == SmartStatus.allDialog) {
      await CustomDialog.dismiss(type: DialogType.allDialog);
    } else if (status == SmartStatus.allCustom) {
      await CustomDialog.dismiss(type: DialogType.allCustom);
    } else if (status == SmartStatus.allAttach) {
      await CustomDialog.dismiss(type: DialogType.allAttach);
    }
  }
}
