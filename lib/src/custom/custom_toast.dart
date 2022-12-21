import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_scope.dart';
import 'package:flutter_smart_dialog/src/widget/helper/toast_helper.dart';

import '../data/animation_param.dart';
import '../data/base_dialog.dart';
import '../widget/helper/smart_overlay_entry.dart';

typedef ToastCallback = Function();

class CustomToast extends BaseDialog {
  CustomToast({required SmartOverlayEntry overlayEntry}) : super(overlayEntry);

  Queue<Future<void> Function()> _toastQueue = ListQueue();
  Queue<_ToastInfo> _tempQueue = ListQueue();

  DateTime? _lastTime;

  Timer? _curTime;
  Completer? _curCompleter;

  static Widget? test;

  ///type
  SmartToastType? _lastType;

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
    // debounce
    if (debounce) {
      var now = DateTime.now();
      var debounce =
          _lastTime != null && now.difference(_lastTime!) < SmartDialog.config.toast.debounceTime;
      _lastTime = now;
      if (debounce) return;
    }
    SmartDialog.config.toast.isExist = true;

    ToastCallback showToast = () {
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
        onMask: () => clickMaskDismiss ? _realDismiss() : null,
      );
    };

    Future<void> multiTypeToast() async {
      // provider multiple toast display logic
      if (displayType == SmartToastType.normal) {
        await _normalToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.last) {
        await _lastToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.first) {
        await _firstToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.firstAndLast) {
        await _firstAndLastToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.onlyRefresh) {
        await _onlyRefresh(time: displayTime, widget: widget, onShowToast: showToast);
      }

      afterDismiss();
    }

    //handling different types of toast
    await handleMultiTypeToast(curType: displayType, fun: multiTypeToast);
  }

  ///--------------------------multi type toast--------------------------

  Future<void> _normalToast({
    required Duration time,
    required ToastCallback onShowToast,
  }) async {
    _toastQueue.add(() async {
      //handling special circumstances
      if (_toastQueue.isEmpty) return;
      onShowToast();
      await _toastDelay(time);
      await _realDismiss();
      //remove current toast
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //invoke next toast
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    if (_toastQueue.length == 1) await _toastQueue.first();
  }

  Future<void> _firstToast({
    required Duration time,
    required ToastCallback onShowToast,
  }) async {
    if (_toastQueue.isNotEmpty) return;

    _toastQueue.add(() async {});
    onShowToast();
    await _toastDelay(time);
    await _realDismiss();

    if (_toastQueue.isNotEmpty) _toastQueue.removeLast();
  }

  Future<void> _lastToast({
    required Duration time,
    required ToastCallback onShowToast,
  }) async {
    onShowToast();
    _toastQueue.add(() async {});
    await _toastDelay(time);
    if (_toastQueue.length == 1) await _realDismiss();

    if (_toastQueue.isNotEmpty) _toastQueue.removeLast();
  }

  Future<void> _firstAndLastToast({
    required Duration time,
    required ToastCallback onShowToast,
  }) async {
    _toastQueue.add(() async {
      //handling special circumstances
      if (_toastQueue.isEmpty) return;

      onShowToast();
      await _toastDelay(time);
      await _realDismiss();

      //remove current toast
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //invoke next toast
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    if (_toastQueue.length == 1) await _toastQueue.first();
    if (_toastQueue.length > 2) _toastQueue.remove(_toastQueue.elementAt(1));
  }

  Timer? _onlyTime;
  DialogScope? _onlyDialogScope;
  SmartDialogController? _toastController;

  Future<void> _onlyRefresh({
    required Duration time,
    required Widget widget,
    required ToastCallback onShowToast,
  }) async {
    if (_toastQueue.isNotEmpty) _toastQueue.clear();

    if (_onlyDialogScope == null) {
      _onlyDialogScope = (widget as ToastHelper).child as DialogScope;
      onShowToast();
    } else {
      var scope = _onlyDialogScope!;
      if (_toastController == null) {
        if (scope.controller != null) {
          _toastController = scope.controller;
        } else {
          scope.info.state?.setController(_toastController = SmartDialogController());
        }
      }
      scope.info.state?.replaceBuilder(widget);
      _toastController?.refresh();
    }

    _onlyTime?.cancel();
    _onlyTime = Timer(time, () {
      _realDismiss();
      _onlyTime = null;
      _onlyDialogScope = null;
      _toastController = null;
    });
  }

  ///--------------------------multi type toast--------------------------

  Future<void> handleMultiTypeToast({
    required SmartToastType curType,
    required Future<void> Function() fun,
  }) async {
    _lastType = _lastType ?? curType;
    var useTempQueue = _lastType != curType || _tempQueue.isNotEmpty;
    _lastType = curType;
    if (useTempQueue) {
      _tempQueue.add(_ToastInfo(type: curType, fun: fun));
    } else {
      await fun();
    }
  }

  void afterDismiss() {
    if (_tempQueue.isEmpty && _toastQueue.isEmpty) {
      _lastType = null;
      //reset _table of ListQueue
      _tempQueue = ListQueue();
      _toastQueue = ListQueue();
    }
    if (_tempQueue.isEmpty || _toastQueue.isNotEmpty) return;

    _ToastInfo lastToast = _tempQueue.first;
    List<_ToastInfo> list = [];
    for (var item in _tempQueue) {
      if (item.type != lastToast.type) break;
      lastToast = item;
      list.add(item);
      item.fun();
    }

    list.forEach((element) => _tempQueue.remove(element));
  }

  Future _toastDelay(Duration duration) {
    var completer = _curCompleter = Completer();
    _curTime = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Future<void> _realDismiss() async {
    await mainDialog.dismiss();
    await Future.delayed(SmartDialog.config.toast.intervalTime);
    if (_toastQueue.length > 1) return;
    SmartDialog.config.toast.isExist = false;
  }

  Future<T?> dismiss<T>({bool closeAll = false}) async {
    if (closeAll) _toastQueue.clear();
    _curTime?.cancel();
    if (!(_curCompleter?.isCompleted ?? true)) _curCompleter?.complete();
    await Future.delayed(SmartDialog.config.toast.animationTime);
    await Future.delayed(const Duration(milliseconds: 50));
    return null;
  }
}

class _ToastInfo {
  _ToastInfo({required this.type, required this.fun});

  SmartToastType type;
  Future<void> Function() fun;
}
