import 'dart:async';

import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/pop_monitor/monitor_pop_route.dart';
import 'package:material_ui/material_ui.dart';

import '../config/enum_config.dart';
import '../data/base_dialog.dart';
import '../smart_dialog.dart';
import '../widget/helper/smart_overlay_entry.dart';

class CustomLoading extends BaseDialog {
  CustomLoading({required SmartOverlayEntry overlayEntry})
    : super(overlayEntry);

  Timer? _timer;
  Timer? _displayTimer;
  bool _canDismiss = false;
  Future<void> Function()? _canDismissCallback;

  Future<T?> showLoading<T>({required SmartShowLoadingParam param}) {
    List<SmartNonAnimationType> nonAnimations = [...param.nonAnimationTypes];
    var continueLoading = SmartNonAnimationType.continueLoading_nonAnimation;
    if (SmartDialog.config.loading.isExist &&
        nonAnimations.contains(continueLoading)) {
      nonAnimations.add(SmartNonAnimationType.openDialog_nonAnimation);
    }

    SmartDialog.config.loading.isExist = true;
    MonitorPopRoute.updateOverlayBackState();

    _canDismiss = false;
    _canDismissCallback = null;
    _timer?.cancel();
    _timer = Timer(SmartDialog.config.loading.leastLoadingTime, () {
      _canDismiss = true;
      final callback = _canDismissCallback;
      if (callback != null) unawaited(callback());
    });

    return mainDialog.show<T>(
      param: SmartMainDialogParam(
        widget: param.widget,
        alignment: param.alignment,
        clickMaskDismiss: param.clickMaskDismiss,
        animationType: param.animationType,
        nonAnimationTypes: nonAnimations,
        animationBuilder: param.animationBuilder,
        usePenetrate: param.usePenetrate,
        useAnimation: param.useAnimation,
        animationTime: param.animationTime,
        maskColor: param.maskColor,
        maskWidget: param.maskWidget,
        onDismiss: _handleDismiss(param.onDismiss, param.displayTime),
        useSystem: false,
        reuse: false,
        awaitOverType: SmartDialog.config.loading.awaitOverType,
        maskTriggerType: SmartDialog.config.loading.maskTriggerType,
        ignoreArea: null,
        keepSingle: false,
        onMask: () {
          param.onMask?.call();
          if (!param.clickMaskDismiss) return;
          unawaited(_realDismiss());
        },
      ),
    );
  }

  VoidCallback _handleDismiss(VoidCallback? onDismiss, Duration? displayTime) {
    _displayTimer?.cancel();
    if (displayTime != null) {
      _displayTimer = Timer(displayTime, () {
        unawaited(dismiss());
      });
    }

    return () {
      _displayTimer?.cancel();
      onDismiss?.call();
    };
  }

  Future<void> _realDismiss({CloseType closeType = CloseType.normal}) async {
    SmartDialog.config.loading.isExist = false;
    MonitorPopRoute.updateOverlayBackState();
    await mainDialog.dismiss<void>(closeType: closeType);
  }

  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {
    _canDismissCallback = () => _realDismiss(closeType: closeType);
    if (_canDismiss) {
      _canDismiss = false;
      SmartDialog.config.loading.isExist = false;
      await _canDismissCallback?.call();
    }
  }

  void resetForTest() {
    _timer?.cancel();
    _timer = null;
    _displayTimer?.cancel();
    _displayTimer = null;
    _canDismiss = false;
    _canDismissCallback = null;
  }
}
