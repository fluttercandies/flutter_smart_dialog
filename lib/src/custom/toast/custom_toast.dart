import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/main_dialog.dart';
import 'package:flutter_smart_dialog/src/util/debounce_utils.dart';

import '../../data/animation_param.dart';
import '../../data/base_dialog.dart';
import '../../helper/dialog_proxy.dart';
import '../../util/view_utils.dart';
import '../../widget/helper/dialog_scope.dart';
import '../../widget/helper/smart_overlay_entry.dart';
import '../../widget/helper/toast_helper.dart';
import 'toast_tool.dart';

typedef ToastCallback = Function();

class CustomToast extends BaseDialog {
  CustomToast({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Future<void> showToast({
    required AlignmentGeometry alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required Duration displayTime,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required bool debounce,
    required SmartToastType displayType,
    required Widget widget,
  }) async {
    if (DebounceUtils.instance.banContinue(DebounceType.toast, debounce)) {
      return;
    }

    showToast() {
      SmartDialog.config.toast.isExist = true;
      overlay(DialogProxy.contextToast).insert(overlayEntry);

      mainDialog.show(
        widget: widget,
        alignment: alignment,
        maskColor: maskColor,
        maskWidget: maskWidget,
        animationTime: animationTime,
        animationType: animationType,
        nonAnimationTypes: nonAnimationTypes,
        animationBuilder: animationBuilder,
        useAnimation: useAnimation,
        usePenetrate: usePenetrate,
        onDismiss: onDismiss,
        useSystem: false,
        reuse: false,
        awaitOverType: SmartDialog.config.toast.awaitOverType,
        maskTriggerType: SmartDialog.config.toast.maskTriggerType,
        ignoreArea: null,
        keepSingle: false,
        onMask: () {
          onMask?.call();
          if (!clickMaskDismiss ||
              DebounceUtils.instance.banContinue(DebounceType.mask, true)) {
            return;
          }
          ToastTool.instance.dismiss();
        },
      );
    }

    if (displayType == SmartToastType.normal) {
      await normalToast(
        time: displayTime,
        onShowToast: showToast,
        mainDialog: mainDialog,
      );
    } else if (displayType == SmartToastType.last) {
      await lastToast(
        time: displayTime,
        onShowToast: showToast,
        mainDialog: mainDialog,
      );
    } else if (displayType == SmartToastType.onlyRefresh) {
      await onlyRefresh(
        time: displayTime,
        widget: widget,
        onShowToast: showToast,
        mainDialog: mainDialog,
      );
    } else if (displayType == SmartToastType.multi) {
      await multiToast(
        time: displayTime,
        onShowToast: showToast,
        mainDialog: mainDialog,
      );
    }
  }

  ///--------------------------multi type toast--------------------------

  static Future<void> normalToast({
    required Duration time,
    required ToastCallback onShowToast,
    required MainDialog mainDialog,
    bool newToast = true,
  }) async {
    var toastQueue = ToastTool.instance.toastQueue;
    if (newToast) {
      toastQueue.addLast(ToastInfo(
        type: SmartToastType.normal,
        mainDialog: mainDialog,
        time: time,
        onShowToast: onShowToast,
      ));

      if (toastQueue.length > 1) {
        return;
      }
    }

    var curToast = toastQueue.first;
    curToast.onShowToast();
    await ToastTool.instance.delay(time, onInvoke: () async {
      await ToastTool.instance.dismiss();
      ToastTool.instance.dispatchNext();
    });
  }

  static Future<void> lastToast({
    required Duration time,
    required ToastCallback onShowToast,
    required MainDialog mainDialog,
  }) async {
    var toastQueue = ToastTool.instance.toastQueue;
    if (toastQueue.isNotEmpty) {
      for (var item in toastQueue) {
        item.mainDialog.overlayEntry.remove();
      }
      toastQueue.clear();
      ToastTool.instance.cancelLastDelay();
    }

    toastQueue.addLast(ToastInfo(
      type: SmartToastType.last,
      mainDialog: mainDialog,
      time: time,
      onShowToast: onShowToast,
    ));
    var curToast = toastQueue.first;
    curToast.onShowToast();
    await ToastTool.instance.delay(curToast.time, onInvoke: () {
      ToastTool.instance.dismiss();
    });
  }

  static Timer? _onlyTime;
  static DialogScope? _onlyDialogScope;
  static SmartDialogController? _onlyToastController;

  static Future<void> onlyRefresh({
    required Duration time,
    required Widget? widget,
    required ToastCallback? onShowToast,
    required MainDialog mainDialog,
  }) async {
    var toastQueue = ToastTool.instance.toastQueue;
    if (toastQueue.length >= 2 ||
        (toastQueue.isNotEmpty &&
            toastQueue.first.type != SmartToastType.onlyRefresh)) {
      ToastTool.instance.clearAllToast();
    }

    if (toastQueue.isEmpty) {
      toastQueue.addLast(ToastInfo(
        type: SmartToastType.onlyRefresh,
        mainDialog: mainDialog,
        time: time,
        onShowToast: onShowToast!,
      ));

      _onlyDialogScope = (widget as ToastHelper).child as DialogScope;
      onShowToast.call();
    } else if (_onlyDialogScope != null) {
      onShowToast = null;
      var scope = _onlyDialogScope!;
      if (_onlyToastController == null) {
        if (scope.controller != null) {
          _onlyToastController = scope.controller;
        } else {
          scope.info.action?.setController(
            _onlyToastController = SmartDialogController(),
          );
        }
      }
      scope.info.action?.replaceBuilder(widget);
      _onlyToastController?.refresh();
    }

    _onlyTime?.cancel();
    _onlyTime = Timer(time, () async {
      await ToastTool.instance.dismiss();
      _onlyDialogScope = null;
      _onlyToastController = null;
    });
  }

  static Future<void> multiToast({
    required Duration time,
    required ToastCallback onShowToast,
    required MainDialog mainDialog,
  }) async {
    onShowToast();
    Timer(time, () async {
      await mainDialog.dismiss();
      mainDialog.overlayEntry.remove();
    });
  }

  static Future<T?> dismiss<T>({bool closeAll = false}) async {
    ToastTool.instance.dismiss(closeAll: closeAll);
    await Future.delayed(SmartDialog.config.toast.animationTime);
    await Future.delayed(const Duration(milliseconds: 50));
    return null;
  }
}

class ToastInfo {
  ToastInfo({
    required this.type,
    required this.mainDialog,
    required this.time,
    required this.onShowToast,
  });

  final MainDialog mainDialog;

  final SmartToastType type;

  Duration time;

  final ToastCallback onShowToast;
}
