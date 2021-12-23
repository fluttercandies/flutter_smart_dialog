import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../../flutter_smart_dialog.dart';
import 'base_dialog.dart';

///main function : custom dialog
class CustomDialog extends BaseDialog {
  CustomDialog({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  final String tagKeepSingle = 'keepSingle';

  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required bool clickBgDismiss,
    required bool antiShake,
    required Widget? maskWidget,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    VoidCallback? onDismiss,
  }) async {
    // debounce
    if (!_checkDebounce(antiShake)) return;

    //handle dialog stack
    _handleDialogStack(
      isUseAnimation: isUseAnimation,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
    );

    config.isExist = true;
    config.isExistMain = true;
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
      onBgTap: () => dismiss(),
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
    if (tag != null) proxy.dialogMap.remove(tag);
    proxy.dialogList.remove(info);
    var customDialog = info.dialog;
    await customDialog.mainDialog.dismiss();
    customDialog.overlayEntry.remove();

    if (proxy.dialogList.length != 0) return;
    proxy.config.isExistMain = false;
    if (!proxy.config.isExistLoading) {
      proxy.config.isExist = false;
    }
  }

  void _handleDialogStack({
    required bool isUseAnimation,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
  }) {
    var proxy = DialogProxy.instance;

    if (keepSingle) {
      DialogInfo dialogInfo;
      if (proxy.dialogMap[tagKeepSingle] == null) {
        dialogInfo = DialogInfo(this, backDismiss, isUseAnimation);
        proxy.dialogList.add(dialogInfo);
        proxy.dialogMap[tagKeepSingle] = dialogInfo;
        Overlay.of(DialogProxy.context)!.insert(
          overlayEntry,
          below: proxy.entryLoading,
        );
      }
      dialogInfo = proxy.dialogMap[tagKeepSingle]!;
      mainDialog.overlayEntry = dialogInfo.dialog.overlayEntry;
      return;
    }

    // handle dialog stack
    var dialogInfo = DialogInfo(this, backDismiss, isUseAnimation);
    proxy.dialogList.add(dialogInfo);
    if (tag != null) proxy.dialogMap[tag] = dialogInfo;
    // insert the dialog carrier into the page
    Overlay.of(DialogProxy.context)!.insert(
      overlayEntry,
      below: proxy.entryLoading,
    );
  }

  bool _checkDebounce(bool antiShake) {
    if (!antiShake) return true;

    var proxy = DialogProxy.instance;
    var now = DateTime.now();
    var isShake = proxy.dialogLastTime != null &&
        now.difference(proxy.dialogLastTime!) <
            SmartDialog.config.antiShakeTime;
    proxy.dialogLastTime = now;
    if (isShake) return false;

    return true;
  }
}

class DialogInfo {
  DialogInfo(this.dialog, this.backDismiss, this.isUseAnimation);

  final CustomDialog dialog;

  final bool backDismiss;

  final bool isUseAnimation;
}
