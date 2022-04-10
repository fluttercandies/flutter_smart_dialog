import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_widget.dart';

import '../config/config.dart';
import '../config/enum_config.dart';

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

  final _uniqueKey = UniqueKey();

  BaseController? _controller;
  Completer? _completer;
  VoidCallback? _onDismiss;
  Widget _widget;

  //refuse repeat close
  bool repeatClose = false;

  Future<T?> show<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required Widget? maskWidget,
    required bool clickBgDismiss,
    required VoidCallback onBgTap,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required bool reuse,
  }) {
    //custom dialog
    _widget = SmartDialogWidget(
      key: reuse ? _uniqueKey : UniqueKey(),
      controller: _controller = SmartDialogController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      child: widget,
      onBgTap: onBgTap,
    );

    _handleCommonOperate(onDismiss: onDismiss, useSystem: useSystem);

    //wait dialog dismiss
    var completer = _completer = Completer<T>();
    return completer.future;
  }

  Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required Widget widget,
    required Offset? target,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required bool clickBgDismiss,
    required VoidCallback onBgTap,
    required VoidCallback? onDismiss,
    required bool useSystem,
  }) {
    //attach dialog
    _widget = AttachDialogWidget(
      key: _uniqueKey,
      targetContext: targetContext,
      target: target,
      controller: _controller = AttachDialogController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      highlightBuilder: highlightBuilder,
      clickBgDismiss: clickBgDismiss,
      child: widget,
      onBgTap: onBgTap,
    );

    _handleCommonOperate(onDismiss: onDismiss, useSystem: useSystem);

    //wait dialog dismiss
    var completer = _completer = Completer<T>();
    return completer.future;
  }

  void _handleCommonOperate({
    required VoidCallback? onDismiss,
    required bool useSystem,
  }) {
    repeatClose = false;
    _onDismiss = onDismiss;

    if (useSystem && DialogProxy.contextNavigator != null) {
      var tempWidget = _widget;
      showDialog(
        context: DialogProxy.contextNavigator!,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        useSafeArea: false,
        routeSettings: RouteSettings(name: SmartTag.systemDialog),
        builder: (BuildContext context) => tempWidget,
      );
      _widget = Container();
    }

    //refresh dialog
    overlayEntry.markNeedsBuild();
  }

  Future<void> dismiss<T>({
    bool useSystem = false,
    T? result,
  }) async {
    //dialog prepare dismiss
    _onDismiss?.call();

    //close animation
    await _controller?.dismiss();

    //remove dialog
    _widget = Container();
    overlayEntry.markNeedsBuild();

    if (useSystem && DialogProxy.contextNavigator != null) {
      Navigator.pop(DialogProxy.contextNavigator!);
    }

    //end waiting
    if (!(_completer?.isCompleted ?? true)) {
      _completer?.complete(result);
    }
  }

  Widget getWidget() => _widget;
}
