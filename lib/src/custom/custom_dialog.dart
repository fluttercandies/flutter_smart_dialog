import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';

import '../../flutter_smart_dialog.dart';
import '../data/base_dialog.dart';
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
  CustomDialog({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  static MainDialog? mainDialogSingle;

  DateTime? clickBgLastTime;

  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) async {
    if (!_handleMustOperate(
      isUseAnimation: isUseAnimation,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.custom,
      useSystem: useSystem,
    )) return;
    return mainDialog.show(
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
      useSystem: useSystem,
      reuse: true,
      onBgTap: () {
        if (!_clickBgDebounce()) return;
        dismiss();
      },
    );
  }

  Future<void> showAttach({
    required BuildContext? targetContext,
    required Offset? target,
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required Positioned highlight,
    required HighlightBuilder? highlightBuilder,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) async {
    if (!_handleMustOperate(
      isUseAnimation: isUseAnimation,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.attach,
      useSystem: useSystem,
    )) return;
    return mainDialog.showAttach(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      highlight: highlight,
      highlightBuilder: highlightBuilder,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      useSystem: useSystem,
      onBgTap: () {
        if (!_clickBgDebounce()) return;
        dismiss();
      },
    );
  }

  bool _handleMustOperate({
    required bool isUseAnimation,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool debounce,
    required DialogType type,
    required bool useSystem,
  }) {
    // debounce
    if (!_checkDebounce(debounce)) return false;

    //handle dialog stack
    _handleDialogStack(
      isUseAnimation: isUseAnimation,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      type: type,
      useSystem: useSystem,
    );

    config.isExist = true;
    config.isExistMain = true;

    return true;
  }

  void _handleDialogStack({
    required bool isUseAnimation,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required DialogType type,
    required bool useSystem,
  }) {
    var proxy = DialogProxy.instance;

    if (keepSingle) {
      DialogInfo dialogInfo;
      if (proxy.dialogMap[SmartTag.keepSingle] == null) {
        dialogInfo = DialogInfo(
          dialog: this,
          backDismiss: backDismiss,
          isUseAnimation: isUseAnimation,
          type: type,
          tag: SmartTag.keepSingle,
          useSystem: useSystem,
        );
        proxy.dialogQueue.add(dialogInfo);
        proxy.dialogMap[SmartTag.keepSingle] = dialogInfo;
        Overlay.of(DialogProxy.contextOverlay)!.insert(
          overlayEntry,
          below: proxy.entryLoading,
        );
        mainDialogSingle = mainDialog;
      }

      mainDialog = mainDialogSingle!;
      return;
    }

    // handle dialog stack
    var dialogInfo = DialogInfo(
      dialog: this,
      backDismiss: backDismiss,
      isUseAnimation: isUseAnimation,
      type: type,
      tag: tag,
      useSystem: useSystem,
    );
    proxy.dialogQueue.add(dialogInfo);
    if (tag != null) proxy.dialogMap[tag] = dialogInfo;
    // insert the dialog carrier into the page
    Overlay.of(DialogProxy.contextOverlay)!.insert(
      overlayEntry,
      below: proxy.entryLoading,
    );
  }

  bool _checkDebounce(bool debounce) {
    if (!debounce) return true;

    var proxy = DialogProxy.instance;
    var now = DateTime.now();
    var isShake = proxy.dialogLastTime != null &&
        now.difference(proxy.dialogLastTime!) < SmartDialog.config.debounceTime;
    proxy.dialogLastTime = now;
    if (isShake) return false;

    return true;
  }

  bool _clickBgDebounce() {
    var now = DateTime.now();
    var isShake = clickBgLastTime != null &&
        now.difference(clickBgLastTime!) < Duration(milliseconds: 500);
    clickBgLastTime = now;
    if (isShake) return false;

    return true;
  }

  static Future<void> dismiss({
    DialogType type = DialogType.dialog,
    bool back = false,
    String? tag,
  }) async {
    if (type == DialogType.dialog) {
      await _closeSingle(DialogType.dialog, back, tag);
    } else if (type == DialogType.custom) {
      await _closeSingle(DialogType.custom, back, tag);
    } else if (type == DialogType.attach) {
      await _closeSingle(DialogType.attach, back, tag);
    } else if (type == DialogType.allDialog) {
      await _closeAll(DialogType.dialog, back, tag);
    } else if (type == DialogType.allCustom) {
      await _closeAll(DialogType.custom, back, tag);
    } else if (type == DialogType.allAttach) {
      await _closeAll(DialogType.attach, back, tag);
    }
  }

  static Future<void> _closeAll(DialogType type, bool back, String? tag) async {
    int length = DialogProxy.instance.dialogQueue.length;
    for (int i = 0; i < length; i++) {
      await _closeSingle(type, back, tag);
    }
  }

  static Future<void> _closeSingle(
    DialogType type,
    bool back,
    String? tag,
  ) async {
    var info = _getDialog(type, back, tag);
    if (info == null) return;

    //handle close dialog
    var proxy = DialogProxy.instance;
    if (info.tag != null) proxy.dialogMap.remove(info.tag);
    proxy.dialogQueue.remove(info);
    var customDialog = info.dialog;
    await customDialog.mainDialog.dismiss(useSystem: info.useSystem);
    customDialog.overlayEntry.remove();

    if (proxy.dialogQueue.isNotEmpty) return;
    proxy.config.isExistMain = false;
    if (!proxy.config.isExistLoading) proxy.config.isExist = false;
  }

  static DialogInfo? _getDialog(DialogType type, bool back, String? tag) {
    var proxy = DialogProxy.instance;
    if (proxy.dialogQueue.isEmpty) return null;

    DialogInfo? info;
    var dialogQueue = proxy.dialogQueue;
    var list = dialogQueue.toList();
    int length = dialogQueue.length;
    for (var i = length - 1; i >= 0; i--) {
      if (dialogQueue.isEmpty) break;
      var item = list[i];
      if (type == DialogType.dialog || item.type == type) {
        info = item;
        break;
      }
    }

    DialogInfo? infoMap = tag == null ? null : proxy.dialogMap[tag];
    info = infoMap ?? info;
    //handle prohibiting back event
    if (info != null && (!info.backDismiss && back)) return null;

    return info;
  }
}
