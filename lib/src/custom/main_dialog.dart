import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_widget.dart';

import '../config/enum_config.dart';
import '../data/animation_param.dart';
import '../widget/helper/smart_overlay_entry.dart';

///main function : customize dialog
class MainDialog {
  MainDialog({required this.overlayEntry}) : _widget = Container();

  ///OverlayEntry instance
  final SmartOverlayEntry overlayEntry;
  final _uniqueKey = UniqueKey();

  bool visible = true;
  BaseController? _controller;
  Completer<dynamic>? _completer;
  VoidCallback? _onDismiss;
  Widget _widget;
  SmartAwaitOverType _awaitOverType = SmartAwaitOverType.dialogDismiss;

  Future<T?> show<T>({
    required Widget widget,
    required Alignment alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback onMask,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required bool reuse,
    required SmartAwaitOverType awaitOverType,
    required SmartMaskTriggerType maskTriggerType,
    required AnimationBuilder? animationBuilder,
    required Rect? ignoreArea,
    required bool keepSingle,
  }) {
    //custom dialog
    _widget = SmartDialogWidget(
      key: reuse ? _uniqueKey : UniqueKey(),
      controller: _controller = SmartDialogWidgetController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: nonAnimationTypes,
        keepSingle: keepSingle,
      ),
      animationBuilder: animationBuilder,
      maskColor: maskColor,
      maskWidget: maskWidget,
      onMask: onMask,
      maskTriggerType: maskTriggerType,
      ignoreArea: ignoreArea,
      child: widget,
    );

    _handleCommonOperate(
      animationTime: animationTime,
      onDismiss: onDismiss,
      useSystem: useSystem,
      awaitOverType: awaitOverType,
    );

    //wait dialog dismiss
    var completer = _completer = Completer<T?>();
    return completer.future;
  }

  Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required Widget widget,
    required TargetBuilder? targetBuilder,
    required ReplaceBuilder? replaceBuilder,
    required AdjustBuilder? adjustBuilder,
    required Alignment alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required ScalePointBuilder? scalePointBuilder,
    required Color maskColor,
    required Widget? maskWidget,
    required Rect? maskIgnoreArea,
    required SmartMaskTriggerType maskTriggerType,
    required VoidCallback onMask,
    required HighlightBuilder? highlightBuilder,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required SmartAwaitOverType awaitOverType,
    required bool keepSingle,
  }) {
    //attach dialog
    _widget = AttachDialogWidget(
      key: _uniqueKey,
      targetContext: targetContext,
      targetBuilder: targetBuilder,
      replaceBuilder: replaceBuilder,
      adjustBuilder: adjustBuilder,
      controller: _controller = AttachDialogController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: nonAnimationTypes,
        keepSingle: keepSingle,
      ),
      animationBuilder: animationBuilder,
      scalePointBuilder: scalePointBuilder,
      maskColor: maskColor,
      maskWidget: maskWidget,
      maskTriggerType: maskTriggerType,
      onMask: onMask,
      maskIgnoreArea: maskIgnoreArea,
      highlightBuilder: highlightBuilder,
      child: widget,
    );

    _handleCommonOperate(
      animationTime: animationTime,
      onDismiss: onDismiss,
      useSystem: useSystem,
      awaitOverType: awaitOverType,
    );

    //wait dialog dismiss
    var completer = _completer = Completer<T?>();
    return completer.future;
  }

  List<SmartNonAnimationType> processNonAnimationTypes({
    required List<SmartNonAnimationType> nonAnimationTypes,
    required bool keepSingle,
  }) {
    List<SmartNonAnimationType> nonAnimations = [...nonAnimationTypes];
    var continueKeepSingle = SmartNonAnimationType.continueKeepSingle;
    if (nonAnimations.contains(continueKeepSingle) &&
        keepSingle &&
        _completer != null) {
      nonAnimations.add(SmartNonAnimationType.openDialog_nonAnimation);
    }

    return nonAnimations;
  }

  void _handleCommonOperate({
    required Duration animationTime,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required SmartAwaitOverType awaitOverType,
  }) {
    _awaitOverType = awaitOverType;

    //SmartAwaitOverType.none
    Future.delayed(const Duration(milliseconds: 10), () {
      _handleAwaitOver(awaitOverType: SmartAwaitOverType.none);
    });

    //SmartAwaitOverType.dialogAppear
    Future.delayed(animationTime, () {
      _handleAwaitOver(awaitOverType: SmartAwaitOverType.dialogAppear);
    });

    _onDismiss = onDismiss;

    if (useSystem && DialogProxy.contextNavigator != null) {
      var tempWidget = _widget;
      _widget = Container();
      ViewUtils.addSafeUse(() {
        showDialog(
          context: DialogProxy.contextNavigator!,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          useSafeArea: false,
          routeSettings: const RouteSettings(name: SmartTag.systemDialog),
          builder: (BuildContext context) => tempWidget,
        );
      });
    }

    //refresh dialog
    overlayEntry.markNeedsBuild();
  }

  void _handleAwaitOver<T>({
    required SmartAwaitOverType awaitOverType,
    T? result,
  }) {
    if (awaitOverType == _awaitOverType) {
      if (!(_completer?.isCompleted ?? true)) _completer?.complete(result);
    }
  }

  Future<void> dismiss<T>({
    bool useSystem = false,
    T? result,
    CloseType closeType = CloseType.normal,
  }) async {
    //dialog prepare dismiss
    _onDismiss?.call();

    //close animation
    await _controller?.dismiss(closeType: closeType);

    //remove dialog
    _widget = Container();
    overlayEntry.markNeedsBuild();

    if (useSystem && DialogProxy.contextNavigator != null) {
      Navigator.pop(DialogProxy.contextNavigator!);
    }

    // safety await
    await ViewUtils.awaitPostFrame();

    //end waiting
    _handleAwaitOver<T>(
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      result: result,
    );
  }

  Widget getWidget() => Offstage(offstage: !visible, child: _widget);
}
