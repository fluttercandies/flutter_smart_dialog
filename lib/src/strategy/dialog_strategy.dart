import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/strategy/action.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

///main function : customize dialog
class DialogStrategy extends DialogAction {
  DialogStrategy({
    required this.config,
    required this.overlayEntry,
  }) : _widget = Container();

  ///OverlayEntry instance
  final OverlayEntry overlayEntry;

  ///config info
  final Config config;

  GlobalKey<SmartDialogViewState>? _key;
  Completer? _completer;
  VoidCallback? _onDismiss;
  Widget _widget;

  @override
  Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignment,
    bool? isPenetrate,
    bool? isUseAnimation,
    Duration? animationDuration,
    bool? isLoading,
    Color? maskColor,
    Widget? maskWidget,
    bool? clickBgDismiss,
    VoidCallback? onDismiss,
  }) async {
    _onDismiss = onDismiss;
    //展示弹窗
    var globalKey = GlobalKey<SmartDialogViewState>();
    _widget = SmartDialogView(
      key: globalKey,
      alignment: alignment ?? config.alignment,
      isPenetrate: isPenetrate ?? config.isPenetrate,
      isUseAnimation: isUseAnimation ?? config.isUseAnimation,
      animationDuration: animationDuration ?? config.animationDuration,
      isLoading: isLoading ?? config.isLoading,
      maskColor: maskColor ?? config.maskColor,
      maskWidget: maskWidget ?? config.maskWidget,
      clickBgDismiss: clickBgDismiss ?? config.clickBgDismiss,
      child: widget,
      onBgTap: () => dismiss(),
    );
    overlayEntry.markNeedsBuild();

    config.isExistMain = true;
    _key = globalKey;
    _completer = Completer();
    return _completer!.future;
  }

  @override
  Future<void> dismiss() async {
    _widget = Container();
    _onDismiss?.call();
    config.isExistMain = false;

    var state = _key?.currentState;
    if (!(_completer?.isCompleted ?? true)) {
      _completer?.complete();
    }
    await state?.dismiss();

    overlayEntry.markNeedsBuild();
  }

  @override
  Widget getWidget() {
    return _widget;
  }
}
