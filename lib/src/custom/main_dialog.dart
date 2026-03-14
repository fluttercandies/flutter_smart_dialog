import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/show_param.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';
import 'package:flutter_smart_dialog/src/widget/smart_dialog_widget.dart';

import '../config/enum_config.dart';
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
    required SmartMainDialogParam param,
  }) {
    //custom dialog
    _widget = SmartDialogWidget(
      key: param.reuse ? _uniqueKey : UniqueKey(),
      controller: _controller = SmartDialogWidgetController(),
      alignment: param.alignment,
      usePenetrate: param.usePenetrate,
      useAnimation: param.useAnimation,
      animationTime: param.animationTime,
      animationType: param.animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: param.nonAnimationTypes,
        keepSingle: param.keepSingle,
      ),
      animationBuilder: param.animationBuilder,
      maskColor: param.maskColor,
      maskWidget: param.maskWidget,
      onMask: param.onMask ?? () {},
      maskTriggerType: param.maskTriggerType,
      ignoreArea: param.ignoreArea,
      child: param.widget,
    );

    _handleCommonOperate(
      animationTime: param.animationTime,
      onDismiss: param.onDismiss,
      useSystem: param.useSystem,
      awaitOverType: param.awaitOverType,
    );

    //wait dialog dismiss
    var completer = _completer = Completer<T?>();
    return completer.future;
  }

  Future<T?> showAttach<T>({
    required SmartMainAttachParam param,
  }) {
    //attach dialog
    _widget = AttachDialogWidget(
      key: _uniqueKey,
      targetContext: param.targetContext,
      targetBuilder: param.targetBuilder,
      replaceBuilder: param.replaceBuilder,
      adjustBuilder: param.adjustBuilder,
      controller: _controller = AttachDialogController(),
      alignment: param.alignment,
      usePenetrate: param.usePenetrate,
      useAnimation: param.useAnimation,
      animationTime: param.animationTime,
      animationType: param.animationType,
      nonAnimationTypes: processNonAnimationTypes(
        nonAnimationTypes: param.nonAnimationTypes,
        keepSingle: param.keepSingle,
      ),
      animationBuilder: param.animationBuilder,
      scalePointBuilder: param.scalePointBuilder,
      maskColor: param.maskColor,
      maskWidget: param.maskWidget,
      maskTriggerType: param.maskTriggerType,
      onMask: param.onMask ?? () {},
      maskIgnoreArea: param.maskIgnoreArea,
      highlightBuilder: param.highlightBuilder,
      child: param.widget,
    );

    _handleCommonOperate(
      animationTime: param.animationTime,
      onDismiss: param.onDismiss,
      useSystem: param.useSystem,
      awaitOverType: param.awaitOverType,
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
