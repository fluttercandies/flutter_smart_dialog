import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/monitor_widget_helper.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

import '../config/enum_config.dart';
import '../data/base_dialog.dart';
import '../data/notify_info.dart';
import '../kit/debounce_utils.dart';
import '../kit/typedef.dart';
import '../smart_dialog.dart';
import '../widget/helper/smart_overlay_entry.dart';

///main function : custom dialog
class CustomDialog extends BaseDialog {
  CustomDialog({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Future<T?> show<T>({
    required SmartShowCustomParam param,
  }) {
    if (DebounceUtils.instance
        .banContinue(DebounceType.custom, param.debounce)) {
      return Future.value(null);
    }

    final dialogInfo = _handleMustOperate(
      tag: param.tag,
      keepSingle: param.keepSingle,
      debounce: param.debounce,
      type: DialogType.custom,
      permanent: param.permanent,
      useSystem: param.useSystem,
      bindPage: param.bindPage,
      bindWidget: param.bindWidget,
      displayTime: param.displayTime,
      backType: param.backType,
      onBack: param.onBack,
    );
    return mainDialog.show<T>(
      param: SmartMainDialogParam(
        widget: param.widget,
        alignment: param.alignment,
        clickMaskDismiss: param.clickMaskDismiss,
        animationType: param.animationType,
        nonAnimationTypes: param.nonAnimationTypes,
        animationBuilder: param.animationBuilder,
        usePenetrate: param.usePenetrate,
        useAnimation: param.useAnimation,
        animationTime: param.animationTime,
        maskColor: param.maskColor,
        maskWidget: param.maskWidget,
        onDismiss:
            _handleDismiss(param.onDismiss, param.displayTime, dialogInfo),
        useSystem: param.useSystem,
        reuse: true,
        awaitOverType: SmartDialog.config.custom.awaitOverType,
        maskTriggerType: SmartDialog.config.custom.maskTriggerType,
        ignoreArea: param.ignoreArea,
        keepSingle: param.keepSingle,
        onMask: () {
          param.onMask?.call();
          if (!param.clickMaskDismiss ||
              DebounceUtils.instance.banContinue(DebounceType.mask, true) ||
              param.permanent) {
            return;
          }
          dismiss(closeType: CloseType.mask, tag: dialogInfo.tag);
        },
      ),
    );
  }

  Future<T?> showAttach<T>({
    required SmartShowAttachParam param,
  }) {
    if (DebounceUtils.instance
        .banContinue(DebounceType.attach, param.debounce)) {
      return Future.value(null);
    }

    final dialogInfo = _handleMustOperate(
      tag: param.tag,
      keepSingle: param.keepSingle,
      debounce: param.debounce,
      type: DialogType.attach,
      permanent: param.permanent,
      useSystem: param.useSystem,
      bindPage: param.bindPage,
      bindWidget: param.bindWidget,
      displayTime: param.displayTime,
      backType: param.backType,
      onBack: param.onBack,
    );
    return mainDialog.showAttach<T>(
      param: SmartMainAttachParam(
        targetContext: param.targetContext,
        widget: param.widget,
        targetBuilder: param.targetBuilder,
        replaceBuilder: param.replaceBuilder,
        adjustBuilder: param.adjustBuilder,
        alignment: param.alignment,
        clickMaskDismiss: param.clickMaskDismiss,
        animationType: param.animationType,
        nonAnimationTypes: param.nonAnimationTypes,
        animationBuilder: param.animationBuilder,
        scalePointBuilder: param.scalePointBuilder,
        usePenetrate: param.usePenetrate,
        useAnimation: param.useAnimation,
        animationTime: param.animationTime,
        maskColor: param.maskColor,
        maskWidget: param.maskWidget,
        maskIgnoreArea: param.maskIgnoreArea,
        onMask: () {
          param.onMask?.call();
          if (!param.clickMaskDismiss ||
              DebounceUtils.instance.banContinue(DebounceType.mask, true) ||
              param.permanent) {
            return;
          }
          dismiss(closeType: CloseType.mask, tag: dialogInfo.tag);
        },
        highlightBuilder: param.highlightBuilder,
        onDismiss:
            _handleDismiss(param.onDismiss, param.displayTime, dialogInfo),
        maskTriggerType: SmartDialog.config.attach.maskTriggerType,
        useSystem: param.useSystem,
        awaitOverType: SmartDialog.config.attach.awaitOverType,
        keepSingle: param.keepSingle,
      ),
    );
  }

  VoidCallback _handleDismiss(
    VoidCallback? onDismiss,
    Duration? displayTime,
    DialogInfo dialogInfo,
  ) {
    if (dialogInfo.tag == SmartTag.keepSingle) {
      dialogInfo.displayTimer?.cancel();
    }

    Timer? timer;
    final tag = dialogInfo.tag;
    if (displayTime != null && tag != null) {
      timer = Timer(displayTime, () => dismiss(tag: tag));
      dialogInfo.displayTimer = timer;
    }

    return () {
      timer?.cancel();
      onDismiss?.call();
    };
  }

  DialogInfo _handleMustOperate({
    required String? tag,
    required bool keepSingle,
    required bool debounce,
    required DialogType type,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
    required BuildContext? bindWidget,
    required Duration? displayTime,
    required SmartBackType? backType,
    required SmartOnBack? onBack,
  }) {
    SmartDialog.config.custom.isExist = DialogType.custom == type;
    SmartDialog.config.attach.isExist = DialogType.attach == type;

    DialogInfo dialogInfo;
    if (keepSingle) {
      var singleDialogInfo = _getDialog(tag: tag ?? SmartTag.keepSingle);
      if (singleDialogInfo == null) {
        singleDialogInfo = DialogInfo(
          dialog: this,
          type: type,
          tag: tag ?? SmartTag.keepSingle,
          permanent: permanent,
          useSystem: useSystem,
          bindPage: bindPage,
          route: RouteRecord.curRoute,
          bindWidget: bindWidget,
          backType: backType,
          onBack: onBack,
        );
        _pushDialog(singleDialogInfo);
      }
      mainDialog = singleDialogInfo.dialog.mainDialog;
      dialogInfo = singleDialogInfo;
    } else {
      tag = tag ?? '${hashCode + Random().nextDouble()}';

      // handle dialog stack
      dialogInfo = DialogInfo(
        dialog: this,
        type: type,
        tag: tag,
        permanent: permanent,
        useSystem: useSystem,
        bindPage: bindPage,
        route: RouteRecord.curRoute,
        bindWidget: bindWidget,
        backType: backType,
        onBack: onBack,
      );
      _pushDialog(dialogInfo);
    }

    return dialogInfo;
  }

  void _pushDialog(DialogInfo dialogInfo) {
    var proxy = DialogProxy.instance;
    if (dialogInfo.permanent) {
      proxy.dialogQueue.addFirst(dialogInfo);
    } else {
      proxy.dialogQueue.addLast(dialogInfo);
    }
    if (dialogInfo.bindWidget != null) {
      MonitorWidgetHelper.instance.monitorDialogQueue.add(dialogInfo);
    }

    // insert the dialog carrier into the page
    ViewUtils.addSafeUse(() {
      NotifyInfo? firstNotify =
          proxy.notifyQueue.isNotEmpty ? proxy.notifyQueue.first : null;
      BuildContext overlayContext = dialogInfo.type == DialogType.custom
          ? DialogProxy.contextCustom
          : DialogProxy.contextAttach;
      try {
        overlay(overlayContext).insert(
          overlayEntry,
          below: firstNotify != null
              ? firstNotify.dialog.overlayEntry
              : proxy.entryLoading,
        );
      } catch (e) {
        overlay(overlayContext).insert(overlayEntry);
      }
    });
  }

  static Future<void>? dismiss<T>({
    DialogType type = DialogType.dialog,
    String? tag,
    T? result,
    bool force = false,
    CloseType closeType = CloseType.normal,
  }) {
    if (type == DialogType.dialog ||
        type == DialogType.custom ||
        type == DialogType.attach) {
      return _closeSingle<T>(
        type: type,
        tag: tag,
        result: result,
        force: force,
        closeType: closeType,
      );
    } else {
      DialogType? allType;
      if (type == DialogType.allDialog) allType = DialogType.dialog;
      if (type == DialogType.allCustom) allType = DialogType.custom;
      if (type == DialogType.allAttach) allType = DialogType.attach;
      if (allType == null) return null;

      return _closeAll<T>(
        type: allType,
        tag: tag,
        result: result,
        force: force,
        closeType: closeType,
      );
    }
  }

  static Future<void> _closeAll<T>({
    required DialogType type,
    required String? tag,
    required T? result,
    required bool force,
    required CloseType closeType,
  }) async {
    for (int i = DialogProxy.instance.dialogQueue.length; i > 0; i--) {
      await _closeSingle<T>(
        type: type,
        tag: tag,
        result: result,
        force: force,
        closeType: closeType,
      );
    }
  }

  static Future<void> _closeSingle<T>({
    required DialogType type,
    required String? tag,
    required T? result,
    required bool force,
    required CloseType closeType,
  }) async {
    var info = _getDialog(
      type: type,
      closeType: closeType,
      tag: tag,
      force: force,
    );
    if (info == null || (info.permanent && !force)) return;

    //handle close dialog
    var proxy = DialogProxy.instance;
    proxy.dialogQueue.remove(info);
    if (info.bindWidget != null) {
      MonitorWidgetHelper.instance.monitorDialogQueue.remove(info);
    }

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
    var customDialog = info.dialog;
    await customDialog.mainDialog.dismiss<T>(
      useSystem: info.useSystem,
      result: result,
      closeType: closeType,
    );
    customDialog.overlayEntry.remove();
  }

  static DialogInfo? _getDialog({
    DialogType type = DialogType.dialog,
    String? tag,
    bool force = false,
    CloseType closeType = CloseType.normal,
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
      var item = list[i];
      if (!item.dialog.mainDialog.visible && !item.useSystem) {
        continue;
      }
      if (type == DialogType.dialog || item.type == type) {
        info = item;
        break;
      }
    }

    return info;
  }
}
