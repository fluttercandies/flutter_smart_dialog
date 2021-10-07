import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/config/config.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_view.dart';

import '../../flutter_smart_dialog.dart';

///main function : customize dialog
class MainStrategy {
  MainStrategy({
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
    //custom dialog
    _widget = SmartDialogView(
      key: _key = GlobalKey<SmartDialogViewState>(),
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
