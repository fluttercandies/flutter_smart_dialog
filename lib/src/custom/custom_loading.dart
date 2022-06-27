import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../data/base_dialog.dart';

class CustomLoading extends BaseDialog {
  CustomLoading({required OverlayEntry overlayEntry}) : super(overlayEntry);

  Timer? _timer;
  bool _canDismiss = false;
  bool _needDismiss = false;

  Future<T?> showLoading<T>({
    required Widget widget,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required bool backDismiss,
  }) {
    DialogProxy.instance.loadingBackDismiss = backDismiss;
    SmartDialog.config.loading.isExist = true;

    _canDismiss = false;
    _needDismiss = false;
    _timer?.cancel();
    _timer = Timer(SmartDialog.config.loading.leastLoadingTime, () {
      _canDismiss = true;
      if (!_needDismiss) return;
      _realDismiss();
    });

    return mainDialog.show<T>(
      widget: widget,
      animationType: animationType,
      alignment: Alignment.center,
      maskColor: maskColor,
      maskWidget: maskWidget,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      onDismiss: onDismiss,
      useSystem: false,
      reuse: true,
      awaitOverType: SmartDialog.config.loading.awaitOverType,
      onMask: () {
        onMask?.call();
        if (!clickMaskDismiss) return;
        _realDismiss();
      },
    );
  }

  Future<void> _realDismiss({bool back = false}) async {
    if (!DialogProxy.instance.loadingBackDismiss && back) return null;

    await mainDialog.dismiss();
    SmartDialog.config.loading.isExist = false;
  }

  Future<void> dismiss({bool back = false}) async {
    if (_canDismiss)
      await _realDismiss(back: back);
    else
      _needDismiss = true;
  }
}
