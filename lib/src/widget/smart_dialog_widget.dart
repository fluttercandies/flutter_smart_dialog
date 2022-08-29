import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/widget/animation/fade_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/scale_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/slide_animation.dart';

import '../config/enum_config.dart';
import 'animation/mask_animation.dart';
import 'helper/mask_event.dart';

class SmartDialogWidget extends StatefulWidget {
  const SmartDialogWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationTime,
    required this.useAnimation,
    required this.animationType,
    required this.maskColor,
    required this.maskWidget,
    required this.maskTriggerType,
  }) : super(key: key);

  /// 内容widget
  final Widget child;

  ///widget controller
  final SmartDialogController controller;

  /// 点击遮罩
  final VoidCallback onMask;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 动画时间
  final Duration animationTime;

  /// 是否使用动画
  final bool useAnimation;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 遮罩点击时, 被触发的时机
  final SmartMaskTriggerType maskTriggerType;

  @override
  _SmartDialogWidgetState createState() => _SmartDialogWidgetState();
}

class _SmartDialogWidgetState extends State<SmartDialogWidget>
    with TickerProviderStateMixin {
  AnimationController? _maskController;
  late AnimationController _bodyController;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  void _resetState() {
    var duration = widget.animationTime;
    if (_maskController == null) {
      _maskController = AnimationController(vsync: this, duration: duration);
      _bodyController = AnimationController(vsync: this, duration: duration);
      _maskController!.forward();
      _bodyController.forward();
    } else {
      _maskController!.duration = duration;
      _bodyController.duration = duration;

      _bodyController.value = 0;
      _bodyController.forward();
    }

    //bind controller
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant SmartDialogWidget oldWidget) {
    if (oldWidget.child != widget.child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      //暗色背景widget动画
      MaskEvent(
        maskTriggerType: widget.maskTriggerType,
        onMask: widget.onMask,
        child: MaskAnimation(
          controller: _maskController!,
          maskColor: widget.maskColor,
          maskWidget: widget.maskWidget,
          usePenetrate: widget.usePenetrate,
        ),
      ),

      //内容Widget动画
      Container(
        alignment: widget.alignment,
        child: widget.useAnimation ? _buildBodyAnimation() : widget.child,
      ),
    ]);
  }

  Widget _buildBodyAnimation() {
    var child = widget.child;
    var type = widget.animationType;
    Widget fade = FadeAnimation(controller: _bodyController, child: child);
    Widget scale = ScaleAnimation(controller: _bodyController, child: child);
    Widget slide = SlideAnimation(
      controller: _bodyController,
      child: child,
      alignment: widget.alignment,
    );
    Widget animation = fade;

    //select different animation
    if (type == SmartAnimationType.fade) {
      animation = fade;
    } else if (type == SmartAnimationType.scale) {
      animation = scale;
    } else if (type == SmartAnimationType.centerFade_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animation = fade;
      } else {
        animation = slide;
      }
    } else if (type == SmartAnimationType.centerScale_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animation = scale;
      } else {
        animation = slide;
      }
    }
    return animation;
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_maskController == null) return;

    _maskController!.reverse();
    _bodyController.reverse();
    if (widget.useAnimation) {
      await Future.delayed(widget.animationTime);
    }
  }

  @override
  void dispose() {
    _maskController?.dispose();
    _maskController = null;
    _bodyController.dispose();

    super.dispose();
  }
}

class SmartDialogController extends BaseController {
  _SmartDialogWidgetState? _state;

  void _bind(_SmartDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    try {
      await _state?.dismiss();
    } catch (e) {
      print("-------------------------------------------------------------");
      print("SmartDialog error: ${e.toString()}");
      print("-------------------------------------------------------------");
    }
    _state = null;
  }
}
