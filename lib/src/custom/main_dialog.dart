import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/config.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

///main function : customize dialog
class MainDialog {
  MainDialog({
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

  Future<void> show({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool isPenetrate,
    required bool isUseAnimation,
    required Duration animationDuration,
    required bool isLoading,
    required Color maskColor,
    required Widget? maskWidget,
    required bool clickBgDismiss,
    required SmartDialogVoidCallBack onBgTap,
    VoidCallback? onDismiss,
  }) async {
    _onDismiss = onDismiss;
    //custom dialog
    _widget = SmartDialogView(
      key: _key = GlobalKey<SmartDialogViewState>(),
      alignment: alignment,
      isPenetrate: isPenetrate,
      isUseAnimation: isUseAnimation,
      animationDuration: animationDuration,
      isLoading: isLoading,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      child: widget,
      onBgTap: onBgTap,
    );

    //refresh dialog
    overlayEntry.markNeedsBuild();

    //wait dialog dismiss
    _completer = Completer();
    return _completer!.future;
  }

  Future<void> dismiss() async {
    //reset widget
    _widget = Container();
    _onDismiss?.call();

    //close animation
    var state = _key?.currentState;
    await state?.dismiss();

    //refresh dialog
    overlayEntry.markNeedsBuild();

    //end waiting
    if (!(_completer?.isCompleted ?? true)) {
      _completer?.complete();
    }
  }

  Widget getWidget() {
    return _widget;
  }
}
