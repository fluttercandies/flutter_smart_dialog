import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';

import '../config/enum_config.dart';
import '../data/base_dialog.dart';
import '../smart_dialog.dart';
import 'main_dialog.dart';

enum DialogType {
  dialog,
  custom,
  attach,
  allDialog,
  allCustom,
  allAttach,
}

///main function : custom dialog
class CustomDialog extends BaseDialog {
  CustomDialog({required OverlayEntry overlayEntry}) : super(overlayEntry);

  static MainDialog? mainDialogSingle;

  DateTime? clickMaskLastTime;

  Future<T?> show<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickMaskDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (!_handleMustOperate(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.custom,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    )) return Future.value(null);
    return mainDialog.show<T>(
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      onDismiss: onDismiss,
      useSystem: useSystem,
      reuse: true,
      onMask: () {
        onMask?.call();
        if (!clickMaskDismiss || !_clickMaskDebounce() || permanent) return;
        dismiss();
      },
    );
  }

  Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required Offset? target,
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickMaskDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (!_handleMustOperate(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.attach,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    )) return Future.value(null);
    return mainDialog.showAttach<T>(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      highlightBuilder: highlightBuilder,
      maskWidget: maskWidget,
      onDismiss: onDismiss,
      useSystem: useSystem,
      onMask: () {
        onMask?.call();
        if (!clickMaskDismiss || !_clickMaskDebounce() || permanent) return;
        dismiss();
      },
    );
  }

  bool _handleMustOperate({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool debounce,
    required DialogType type,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    // debounce
    if (!_checkDebounce(debounce, type)) return false;

    //handle dialog stack
    _handleDialogStack(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      type: type,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    );

    SmartDialog.config.custom.isExist = DialogType.custom == type;
    SmartDialog.config.attach.isExist = DialogType.attach == type;
    return true;
  }

  void _handleDialogStack({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required DialogType type,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (keepSingle) {
      DialogInfo? dialogInfo = _getDialog(tag: SmartTag.keepSingle);
      if (dialogInfo == null) {
        dialogInfo = DialogInfo(
          dialog: this,
          backDismiss: backDismiss,
          type: type,
          tag: SmartTag.keepSingle,
          permanent: permanent,
          useSystem: useSystem,
          bindPage: bindPage,
          route: RouteRecord.curRoute,
        );
        _pushDialog(dialogInfo);
        mainDialogSingle = mainDialog;
      }

      mainDialog = mainDialogSingle!;
      return;
    }

    // handle dialog stack
    var dialogInfo = DialogInfo(
      dialog: this,
      backDismiss: backDismiss,
      type: type,
      tag: tag,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
      route: RouteRecord.curRoute,
    );
    _pushDialog(dialogInfo);
  }

  void _pushDialog(DialogInfo dialogInfo) {
    var proxy = DialogProxy.instance;
    if (dialogInfo.permanent) {
      proxy.dialogQueue.addFirst(dialogInfo);
    } else {
      proxy.dialogQueue.addLast(dialogInfo);
    }
    // insert the dialog carrier into the page
    Overlay.of(DialogProxy.contextOverlay)!.insert(
      overlayEntry,
      below: proxy.entryLoading,
    );
  }

  bool _checkDebounce(bool debounce, DialogType type) {
    if (!debounce) return true;

    var proxy = DialogProxy.instance;
    var now = DateTime.now();
    var debounceTime = type == DialogType.dialog
        ? SmartDialog.config.custom.debounceTime
        : SmartDialog.config.attach.debounceTime;
    var prohibit = proxy.dialogLastTime != null &&
        now.difference(proxy.dialogLastTime!) < debounceTime;
    proxy.dialogLastTime = now;
    if (prohibit) return false;

    return true;
  }

  bool _clickMaskDebounce() {
    var now = DateTime.now();
    var isShake = clickMaskLastTime != null &&
        now.difference(clickMaskLastTime!) < Duration(milliseconds: 500);
    clickMaskLastTime = now;
    if (isShake) return false;

    return true;
  }

  static Future<void>? dismiss<T>({
    DialogType type = DialogType.dialog,
    bool back = false,
    String? tag,
    T? result,
    bool force = false,
    bool route = false,
  }) {
    if (type == DialogType.dialog ||
        type == DialogType.custom ||
        type == DialogType.attach) {
      return _closeSingle<T>(
        type: type,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    } else {
      DialogType? allType;
      if (type == DialogType.allDialog) allType = DialogType.dialog;
      if (type == DialogType.allCustom) allType = DialogType.custom;
      if (type == DialogType.allAttach) allType = DialogType.attach;
      if (allType == null) return null;

      return _closeAll<T>(
        type: allType,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    }
  }

  static Future<void> _closeAll<T>({
    required DialogType type,
    required bool back,
    required String? tag,
    required T? result,
    required bool force,
    required bool route,
  }) async {
    for (int i = DialogProxy.instance.dialogQueue.length; i > 0; i--) {
      await _closeSingle<T>(
        type: type,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    }
  }

  static Future<void> _closeSingle<T>({
    required DialogType type,
    required bool back,
    required String? tag,
    required T? result,
    required bool force,
    required bool route,
  }) async {
    var info = _getDialog(type: type, back: back, tag: tag, force: force);
    if (info == null || (info.permanent && !force)) return;
    //route close
    if (route && info.bindPage && info.route != RouteRecord.popRoute) return;

    //handle close dialog
    var proxy = DialogProxy.instance;
    proxy.dialogQueue.remove(info);
    var customDialog = info.dialog;

    //check if the queue contains a custom dialog or attach dialog
    proxy.config.custom.isExist = false;
    proxy.config.attach.isExist = false;
    for (var item in proxy.dialogQueue) {
      if (item.type == DialogType.custom) {
        proxy.config.custom.isExist = true;
      } else if (item.type == DialogType.attach) {
        proxy.config.attach.isExist = true;
      }
    }

    //perform a real dismiss
    await customDialog.mainDialog.dismiss<T>(
      useSystem: info.useSystem,
      result: result,
    );
    customDialog.overlayEntry.remove();
  }

  static DialogInfo? _getDialog({
    DialogType type = DialogType.dialog,
    bool back = false,
    String? tag,
    bool force = false,
  }) {
    var proxy = DialogProxy.instance;
    if (proxy.dialogQueue.isEmpty) return null;

    DialogInfo? info;
    var dialogQueue = proxy.dialogQueue;
    var list = dialogQueue.toList();

    //handle dialog with tag
    if (tag != null) {
      for (var i = dialogQueue.length - 1; i >= 0; i--) {
        if (dialogQueue.isEmpty) break;
        if (list[i].tag == tag) info = list[i];
      }
      return info;
    }

    //handle permanent dialog
    if (force) {
      for (var i = dialogQueue.length - 1; i >= 0; i--) {
        if (dialogQueue.isEmpty) break;
        if (list[i].permanent) return list[i];
      }
    }

    //handle normal dialog
    for (var i = dialogQueue.length - 1; i >= 0; i--) {
      if (dialogQueue.isEmpty) break;
      if (type == DialogType.dialog || list[i].type == type) {
        info = list[i];
        break;
      }
    }

    //handle prohibiting back event
    if (info != null && (!info.backDismiss && back)) return null;

    return info;
  }
}
