import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';

import '../../flutter_smart_dialog.dart';
import '../data/base_dialog.dart';
import 'main_dialog.dart';

enum DialogType {
  custom,
  attach,
}

///main function : custom dialog
class CustomDialog extends BaseDialog {
  CustomDialog({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  static MainDialog? mainDialogSingle;

  final String tagKeepSingle = 'keepSingle';

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

  static Future<void> dismiss({bool back = false, String? tag}) async {
    var proxy = DialogProxy.instance;
    var length = proxy.dialogList.length;
    if (length == 0) return;

    var info =
        (tag == null ? proxy.dialogList[length - 1] : proxy.dialogMap[tag]);
    if (info == null || (!info.backDismiss && back)) return;

    //handle close dialog
    if (info.tag != null) proxy.dialogMap.remove(info.tag);
    proxy.dialogList.remove(info);
    var customDialog = info.dialog;
    await customDialog.mainDialog.dismiss(useSystem: info.useSystem);
    customDialog.overlayEntry.remove();

    if (proxy.dialogList.length != 0) return;
    proxy.config.isExistMain = false;
    if (!proxy.config.isExistLoading) {
      proxy.config.isExist = false;
    }
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
      if (proxy.dialogMap[tagKeepSingle] == null) {
        dialogInfo = DialogInfo(
          dialog: this,
          backDismiss: backDismiss,
          isUseAnimation: isUseAnimation,
          type: type,
          tag: tagKeepSingle,
          useSystem: useSystem,
        );
        proxy.dialogList.add(dialogInfo);
        proxy.dialogMap[tagKeepSingle] = dialogInfo;
        Overlay.of(DialogProxy.context)!.insert(
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
    proxy.dialogList.add(dialogInfo);
    if (tag != null) proxy.dialogMap[tag] = dialogInfo;
    // insert the dialog carrier into the page
    Overlay.of(DialogProxy.context)!.insert(
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
}
