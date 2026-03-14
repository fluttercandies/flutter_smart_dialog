import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/custom/main_dialog.dart';
import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/kit/debounce_utils.dart';

import '../../data/base_dialog.dart';
import '../../helper/dialog_proxy.dart';
import '../../kit/view_utils.dart';
import '../../widget/helper/dialog_scope.dart';
import '../../widget/helper/smart_overlay_entry.dart';
import '../../widget/helper/toast_helper.dart';
import 'toast_tool.dart';

typedef ToastCallback = Function();

class CustomToast extends BaseDialog {
  CustomToast({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Future<void> showToast({
    required SmartShowToastParam param,
  }) async {
    if (DebounceUtils.instance
        .banContinue(DebounceType.toast, param.debounce)) {
      return;
    }

    showCurrentToast() {
      SmartDialog.config.toast.isExist = true;
      overlayEntry.remove();
      overlay(DialogProxy.contextToast).insert(overlayEntry);

      mainDialog.show(
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
          onDismiss: param.onDismiss,
          useSystem: false,
          reuse: false,
          awaitOverType: SmartDialog.config.toast.awaitOverType,
          maskTriggerType: SmartDialog.config.toast.maskTriggerType,
          ignoreArea: null,
          keepSingle: false,
          onMask: () {
            param.onMask?.call();
            if (!param.clickMaskDismiss ||
                DebounceUtils.instance.banContinue(DebounceType.mask, true)) {
              return;
            }
            ToastTool.instance.dismiss();
          },
        ),
      );
    }

    try {
      if (param.displayType == SmartToastType.normal) {
        await normalToast(
          time: param.displayTime,
          onShowToast: showCurrentToast,
          mainDialog: mainDialog,
        );
      } else if (param.displayType == SmartToastType.last) {
        await lastToast(
          time: param.displayTime,
          onShowToast: showCurrentToast,
          mainDialog: mainDialog,
        );
      } else if (param.displayType == SmartToastType.onlyRefresh) {
        await onlyRefresh(
          time: param.displayTime,
          widget: param.widget,
          onShowToast: showCurrentToast,
          mainDialog: mainDialog,
        );
      } else if (param.displayType == SmartToastType.multi) {
        await multiToast(
          time: param.displayTime,
          onShowToast: showCurrentToast,
          mainDialog: mainDialog,
        );
      }
    } catch (_) {}
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
        await ViewUtils.awaitPostFrame(onPostFrame: () {
          item.mainDialog.overlayEntry.remove();
        });
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
