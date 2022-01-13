import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';

import '../data/base_dialog.dart';

class CustomToast extends BaseDialog {
  CustomToast({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  List<Future<void> Function()> _toastList = [];

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
    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.isEmpty) return;

      onShowToast();

      await Future.delayed(time);
      //invoke next toast
      if (_toastList.isNotEmpty) _toastList.removeAt(0);
      await dismiss();

      if (_toastList.isNotEmpty) await _toastList[0]();
    });

    if (_toastList.length == 1) await _toastList[0]();
  }

  Future<void> _firstToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    if (_toastList.isNotEmpty) return;

    _toastList.add(() async {});

    onShowToast();

    await Future.delayed(time);
    await dismiss();

    _toastList.removeLast();
  }

  Future<void> _lastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    onShowToast();

    _toastList.add(() async {});
    await Future.delayed(time);
    if (_toastList.length == 1) {
      await dismiss();
    }
    _toastList.removeLast();
  }

  Future<void> _firstAndLastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    _toastList.add(() async {
      //handling special circumstances
      if (_toastList.isEmpty) return;

      onShowToast();

      await Future.delayed(time);
      //invoke next toast
      if (_toastList.isNotEmpty) _toastList.removeAt(0);
      await dismiss();

      if (_toastList.isNotEmpty) await _toastList[0]();
    });

    if (_toastList.length == 1) await _toastList[0]();

    if (_toastList.length > 2) {
      _toastList.removeAt(1);
    }
  }

  Future<void> dismiss() async {
    await mainDialog.dismiss();
    if (_toastList.isNotEmpty) return;

    config.isExistToast = false;
  }
}
