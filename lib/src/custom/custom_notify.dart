import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

import '../config/enum_config.dart';
import '../data/animation_param.dart';
import '../data/base_dialog.dart';
import '../data/notify_info.dart';
import '../smart_dialog.dart';
import '../util/debounce_utils.dart';
import '../widget/helper/smart_overlay_entry.dart';

///main function : notify dialog
class CustomNotify extends BaseDialog {
  CustomNotify({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Future<T?> showNotify<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required Color maskColor,
    required bool clickMaskDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required Duration? displayTime,
    required String? tag,
    required bool keepSingle,
    required SmartBackType backType,
  }) {
    if (DebounceUtils.instance.banContinue(DebounceType.notify, debounce)) {
      return Future.value(null);
    }

    final notifyInfo = _handleMustOperate(
      tag: tag,
      keepSingle: keepSingle,
      debounce: debounce,
      displayTime: displayTime,
      backType: backType,
    );
    return mainDialog.show<T>(
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      nonAnimationTypes: nonAnimationTypes,
      animationBuilder: animationBuilder,
      maskColor: maskColor,
      maskWidget: maskWidget,
      onDismiss: _handleDismiss(onDismiss, displayTime, notifyInfo),
      useSystem: false,
      reuse: true,
      awaitOverType: SmartDialog.config.notify.awaitOverType,
      maskTriggerType: SmartDialog.config.notify.maskTriggerType,
      ignoreArea: null,
      keepSingle: keepSingle,
      onMask: () {
        onMask?.call();
        if (!clickMaskDismiss ||
            DebounceUtils.instance.banContinue(DebounceType.mask, true)) {
          return;
        }
        dismiss(closeType: CloseType.mask);
      },
    );
  }

  VoidCallback _handleDismiss(
    VoidCallback? onDismiss,
    Duration? displayTime,
    NotifyInfo notifyInfo,
  ) {
    if (notifyInfo.tag == SmartTag.keepSingle) {
      notifyInfo.displayTimer?.cancel();
    }

    Timer? timer;
    final tag = notifyInfo.tag;
    if (displayTime != null && tag != null) {
      timer = Timer(displayTime, () => dismiss(tag: tag));
      notifyInfo.displayTimer = timer;
    }

    return () {
      timer?.cancel();
      onDismiss?.call();
    };
  }

  NotifyInfo _handleMustOperate({
    required String? tag,
    required bool keepSingle,
    required bool debounce,
    required Duration? displayTime,
    required SmartBackType backType,
  }) {
    SmartDialog.config.notify.isExist = true;

    NotifyInfo notifyInfo;
    if (keepSingle) {
      var singleNotifyInfo = _getDialog(tag: tag ?? SmartTag.keepSingle);
      if (singleNotifyInfo == null) {
        singleNotifyInfo = NotifyInfo(
          dialog: this,
          tag: tag ?? SmartTag.keepSingle,
          backType: backType,
        );
        _pushDialog(singleNotifyInfo);
      }
      mainDialog = singleNotifyInfo.dialog.mainDialog;
      notifyInfo = singleNotifyInfo;
    } else {
      tag = tag ?? '${hashCode + Random().nextDouble()}';

      // handle dialog stack
      notifyInfo = NotifyInfo(dialog: this, tag: tag, backType: backType);
      _pushDialog(notifyInfo);
    }

    return notifyInfo;
  }

  void _pushDialog(NotifyInfo notifyInfo) {
    var proxy = DialogProxy.instance;
    proxy.notifyQueue.addLast(notifyInfo);

    // insert the dialog carrier into the page
    ViewUtils.addSafeUse(() {
      try {
        overlay(DialogProxy.contextNotify).insert(
          overlayEntry,
          below: proxy.entryLoading,
        );
      } catch (e) {
        overlay(DialogProxy.contextNotify).insert(overlayEntry);
      }
    });
  }

  static Future<void>? dismiss<T>({
    DialogType type = DialogType.notify,
    String? tag,
    T? result,
    bool force = false,
    CloseType closeType = CloseType.normal,
  }) {
    if (type == DialogType.notify) {
      return _closeSingle<T>(tag: tag, result: result, closeType: closeType);
    } else {
      return _closeAll<T>(tag: tag, result: result, closeType: closeType);
    }
  }

  static Future<void> _closeAll<T>({
    required String? tag,
    required T? result,
    required CloseType closeType,
  }) async {
    for (int i = DialogProxy.instance.notifyQueue.length; i > 0; i--) {
      await _closeSingle<T>(
        tag: tag,
        result: result,
        closeType: closeType,
      );
    }
  }

  static Future<void> _closeSingle<T>({
    required String? tag,
    required T? result,
    required CloseType closeType,
  }) async {
    var info = _getDialog(tag: tag);
    if (info == null) return;

    //handle close dialog
    var proxy = DialogProxy.instance;
    proxy.notifyQueue.remove(info);

    if (proxy.notifyQueue.isEmpty) {
      proxy.config.notify.isExist = false;
    }

    //perform a real dismiss
    var customDialog = info.dialog;
    await customDialog.mainDialog.dismiss<T>(
      result: result,
      closeType: closeType,
    );
    customDialog.overlayEntry.remove();
  }

  static NotifyInfo? _getDialog({String? tag}) {
    var proxy = DialogProxy.instance;
    if (proxy.notifyQueue.isEmpty) return null;

    NotifyInfo? info;
    var notifyQueue = proxy.notifyQueue;
    var list = notifyQueue.toList();

    //handle dialog with tag
    if (tag != null) {
      for (var i = notifyQueue.length - 1; i >= 0; i--) {
        if (notifyQueue.isEmpty) break;
        if (list[i].tag == tag) info = list[i];
      }
      return info;
    }

    if (notifyQueue.isNotEmpty) {
      info = list[list.length - 1];
    }

    return info;
  }
}
