import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';

import '../data/base_dialog.dart';

class CustomToast extends BaseDialog {
  CustomToast({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  Queue<Future<void> Function()> _toastQueue = ListQueue();

  DateTime? _lastTime;

  Future<void> showToast({
    required bool clickBgDismiss,
    required bool isLoading,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required Color maskColor,
    required Widget? maskWidget,
    required Duration time,
    required bool debounce,
    required SmartToastType type,
    required Widget widget,
  }) async {
    // debounce
    if (debounce) {
      var now = DateTime.now();
      var isShake = _lastTime != null &&
          now.difference(_lastTime!) < SmartDialog.config.debounceTime;
      _lastTime = now;
      if (isShake) return;
    }
    config.isExistToast = true;

    var showToast = () {
      mainDialog.show(
        widget: widget,
        alignment: Alignment.center,
        maskColor: maskColor,
        maskWidget: maskWidget,
        animationDuration: animationDuration,
        isLoading: isLoading,
        isUseAnimation: isUseAnimation,
        isPenetrate: isPenetrate,
        clickBgDismiss: clickBgDismiss,
        onDismiss: null,
        useSystem: false,
        onBgTap: () => dismiss(),
      );
    };

    // provider multiple toast display logic
    if (type == SmartToastType.normal) {
      await _normalToast(time: time, onShowToast: showToast);
    } else if (type == SmartToastType.first) {
      await _firstToast(time: time, onShowToast: showToast);
    } else if (type == SmartToastType.last) {
      await _lastToast(time: time, onShowToast: showToast);
    } else if (type == SmartToastType.firstAndLast) {
      await _firstAndLastToast(time: time, onShowToast: showToast);
    }
  }

  Future<void> _normalToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    _toastQueue.add(() async {
      //handling special circumstances
      if (_toastQueue.isEmpty) return;
      onShowToast();
      await Future.delayed(time);
      await dismiss();

      //remove current toast
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //invoke next toast
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    if (_toastQueue.length == 1) await _toastQueue.first();
  }

  Future<void> _firstToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    if (_toastQueue.isNotEmpty) return;

    _toastQueue.add(() async {});
    onShowToast();
    await Future.delayed(time);
    await dismiss();

    _toastQueue.removeLast();
  }

  Future<void> _lastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    onShowToast();

    _toastQueue.add(() async {});
    await Future.delayed(time);
    if (_toastQueue.length == 1) await dismiss();

    _toastQueue.removeLast();
  }

  Future<void> _firstAndLastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    _toastQueue.add(() async {
      //handling special circumstances
      if (_toastQueue.isEmpty) return;

      onShowToast();
      await Future.delayed(time);
      await dismiss();

      //remove current toast
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //invoke next toast
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    if (_toastQueue.length == 1) await _toastQueue.first();

    if (_toastQueue.length > 2) {
      var list = _toastQueue.toList();
      list.removeAt(1);
    }
  }

  Future<void> dismiss() async {
    await mainDialog.dismiss();
    if (_toastQueue.isNotEmpty) return;

    config.isExistToast = false;
  }
}
