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

    var curToast = toastQueue.first;
    await curToast.mainDialog.dismiss();
    await Future.delayed(SmartDialog.config.toast.intervalTime);
    curToast.mainDialog.overlayEntry.remove();

    toastQueue.remove(curToast);
    if (closeAll) {
      toastQueue.clear();
    }
    if (toastQueue.length > 1) return;
    SmartDialog.config.toast.isExist = false;
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
