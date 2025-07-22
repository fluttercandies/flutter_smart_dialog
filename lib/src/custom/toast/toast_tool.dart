import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../../../flutter_smart_dialog.dart';
import 'custom_toast.dart';

class ToastTool {
  static ToastTool? _instance;

  static ToastTool get instance => _instance ??= ToastTool._();

  ToastTool._();

  Timer? _curTime;
  Completer<void>? _curCompleter;

  Queue<ToastInfo> toastQueue = ListQueue();

  Future<void> dismiss({bool closeAll = false}) async {
    if (toastQueue.isEmpty) {
      return;
    }

    if (closeAll) {
      clearAllToast();
      SmartDialog.config.toast.isExist = false;
      return;
    }

    var curToast = toastQueue.first;
    toastQueue.remove(curToast);
    if (toastQueue.isEmpty) {
      SmartDialog.config.toast.isExist = false;
    }

    await curToast.mainDialog.dismiss();
    if (curToast.mainDialog.overlayEntry.mounted) {
      curToast.mainDialog.overlayEntry.remove();
      curToast.mainDialog.overlayEntry.dispose();
    }
    await Future.delayed(SmartDialog.config.toast.intervalTime);
  }

  void clearAllToast() {
    if (toastQueue.isEmpty) {
      return;
    }

    cancelLastDelay();
    for (var element in toastQueue) {
      if (element.mainDialog.overlayEntry.mounted) {
        element.mainDialog.overlayEntry.remove();
        element.mainDialog.overlayEntry.dispose();
      }
    }
    toastQueue.clear();
  }

  Future<void> delay(Duration duration, {VoidCallback? onInvoke}) {
    var completer = _curCompleter = Completer();
    _curTime = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
      onInvoke?.call();
    });
    return completer.future;
  }

  void cancelLastDelay() async {
    _curTime?.cancel();
    if (!(_curCompleter?.isCompleted ?? true)) _curCompleter?.complete();
  }

  Future<void> dispatchNext() async {
    if (toastQueue.isEmpty) {
      return;
    }

    var nextToast = toastQueue.first;
    if (nextToast.type == SmartToastType.normal) {
      await CustomToast.normalToast(
        time: nextToast.time,
        onShowToast: nextToast.onShowToast,
        mainDialog: nextToast.mainDialog,
        newToast: false,
      );
    }
  }
}
