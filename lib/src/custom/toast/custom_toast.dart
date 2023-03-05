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
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required Duration displayTime,
    required bool debounce,
    required SmartToastType displayType,
    required Widget widget,
  }) async {
    if (DebounceUtils.instance.banContinue(DebounceType.toast, debounce)) {
      return;
    }

    ToastCallback showToast = () {
      SmartDialog.config.toast.isExist = true;
      try {
        overlay(DialogProxy.contextToast).insert(
          overlayEntry,
          below: DialogProxy.instance.entryToast,
        );
      } catch (e) {
        overlay(DialogProxy.contextToast).insert(overlayEntry);
      }

      mainDialog.show(
        widget: widget,
        alignment: alignment,
        maskColor: maskColor,
        maskWidget: maskWidget,
        animationTime: animationTime,
        animationType: animationType,
        nonAnimationTypes: const [],
        animationBuilder: animationBuilder,
        useAnimation: useAnimation,
        usePenetrate: usePenetrate,
        onDismiss: null,
        useSystem: false,
        reuse: false,
        awaitOverType: SmartDialog.config.toast.awaitOverType,
        maskTriggerType: SmartDialog.config.toast.maskTriggerType,
        ignoreArea: null,
        onMask: () => clickMaskDismiss ? ToastTool.instance.dismiss() : null,
      );
    };

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
    }

    if (toastQueue.length > 1 && toastQueue.first.using) {
      return;
    }

    var curToast = toastQueue.first;
    curToast.using = true;
    curToast.onShowToast();
    await ToastTool.instance.delay(time);
    await ToastTool.instance.dismiss();
    ToastTool.instance.dispatchNext();
  }

  static Future<void> lastToast({
    required Duration time,
    required ToastCallback onShowToast,
    required MainDialog mainDialog,
    bool newToast = true,
  }) async {
    var toastQueue = ToastTool.instance.toastQueue;
    if (newToast) {
      toastQueue.addLast(ToastInfo(
        type: SmartToastType.last,
        mainDialog: mainDialog,
        time: time,
        onShowToast: onShowToast,
      ));
      ToastTool.instance.overLastDelay();
    }

    if (toastQueue.length > 1 && toastQueue.first.using) {
      return;
    }

    var curToast = toastQueue.first;
    curToast.using = true;
    curToast.onShowToast();
    if (toastQueue.length > 1 &&
        toastQueue.elementAt(1).type == SmartToastType.last) {
      toastQueue.remove(curToast);
      curToast.mainDialog.overlayEntry.remove();
    } else {
      await ToastTool.instance.delay(curToast.time);
      await ToastTool.instance.dismiss(curToast: curToast);
    }
    ToastTool.instance.dispatchNext();
  }

  static Timer? _onlyTime;
  static DialogScope? _onlyDialogScope;
  static SmartDialogController? _onlyToastController;

  static Future<void> onlyRefresh({
    required Duration time,
    required Widget? widget,
    required ToastCallback? onShowToast,
    required MainDialog mainDialog,
    bool newToast = true,
  }) async {
    var toastQueue = ToastTool.instance.toastQueue;
    if (toastQueue.isEmpty ||
        (newToast && toastQueue.first.type != SmartToastType.onlyRefresh)) {
      toastQueue.addLast(ToastInfo(
        type: SmartToastType.onlyRefresh,
        mainDialog: mainDialog,
        time: time,
        onShowToast: onShowToast!,
      ));
    }

    if (_onlyDialogScope == null) {
      _onlyDialogScope = (widget as ToastHelper).child as DialogScope;
      onShowToast?.call();
    } else {
      onShowToast = null;
      var scope = _onlyDialogScope!;
      if (_onlyToastController == null) {
        if (scope.controller != null) {
          _onlyToastController = scope.controller;
        } else {
          scope.info.state?.setController(
            _onlyToastController = SmartDialogController(),
          );
        }
      }
      scope.info.state?.replaceBuilder(widget);
      _onlyToastController?.refresh();
    }

    _onlyTime?.cancel();
    _onlyTime = Timer(time, () {
      ToastTool.instance.dismiss();
      _onlyTime = null;
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

  bool using = false;

  final MainDialog mainDialog;

  final SmartToastType type;

  Duration time;

  final ToastCallback onShowToast;
}
