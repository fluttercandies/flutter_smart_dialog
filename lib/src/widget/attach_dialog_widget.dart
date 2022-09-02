import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/animation/highlight_mask_animation.dart';
import 'package:flutter_smart_dialog/src/widget/animation/scale_animation.dart';
import 'package:flutter_smart_dialog/src/widget/helper/dialog_scope.dart';
import 'package:flutter_smart_dialog/src/widget/helper/attach_widget.dart';
import 'package:flutter_smart_dialog/src/widget/helper/mask_event.dart';

import '../config/enum_config.dart';
import '../data/animation_param.dart';
import 'animation/fade_animation.dart';
import 'animation/size_animation.dart';

typedef HighlightBuilder = Positioned Function(
  Offset targetOffset,
  Size targetSize,
);

typedef TargetBuilder = Offset Function(
  Offset targetOffset,
  Size targetSize,
);

typedef ReplaceBuilder = Widget Function(
  Offset targetOffset,
  Size targetSize,
  Offset selfOffset,
  Size selfSize,
);

typedef ScalePointBuilder = Offset Function(Size selfSize);

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.controller,
    required this.animationTime,
    required this.useAnimation,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationType,
    required this.animationBuilder,
    required this.scalePointBuilder,
    required this.maskColor,
    required this.highlightBuilder,
    required this.maskWidget,
    required this.maskTriggerType,
  }) : super(key: key);

  ///target context
  final BuildContext? targetContext;

  /// 自定义坐标点
  final TargetBuilder? targetBuilder;

  final ReplaceBuilder? replaceBuilder;

  /// 是否使用动画
  final bool useAnimation;

  ///动画时间
  final Duration animationTime;

  ///自定义的主体布局
  final Widget child;

  ///widget controller
  final AttachDialogController controller;

  /// 点击背景
  final VoidCallback onMask;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 自定义动画
  final AnimationBuilder? animationBuilder;

  /// 缩放动画的缩放点
  final ScalePointBuilder? scalePointBuilder;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 溶解遮罩,设置高亮位置
  final HighlightBuilder highlightBuilder;

  /// 遮罩点击时, 被触发的时机
  final SmartMaskTriggerType maskTriggerType;

  @override
  _AttachDialogWidgetState createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with TickerProviderStateMixin {
  // animation
  AnimationController? _maskController;
  late AnimationController _bodyController;
  AnimationParam? _animationParam;

  // target info
  RectInfo? _targetRect;
  Alignment? _scaleAlignment;

  late Widget _child;

  @override
  void initState() {
    _child = widget.child;
    _resetState();

    super.initState();
  }

  void _resetState() {
    var duration = widget.animationTime;
    if (_maskController == null) {
      _maskController = AnimationController(vsync: this, duration: duration);
      _bodyController = AnimationController(vsync: this, duration: duration);
      _maskController?.forward();
      _bodyController.forward();
    } else {
      _maskController!.duration = duration;
      _bodyController.duration = duration;

      _bodyController.value = 0;
      _bodyController.forward();
    }

    ViewUtils.addSafeUse(() {
      _animationParam?.onForward?.call();
    });

    //bind controller
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant AttachDialogWidget oldWidget) {
    if (oldWidget.child != _child ||
        oldWidget.targetContext != widget.targetContext ||
        oldWidget.targetBuilder != widget.targetBuilder) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AttachWidget(
      targetContext: widget.targetContext,
      targetBuilder: widget.targetBuilder,
      beforeBuilder: beforeBuilder,
      alignment: widget.alignment,
      originChild: _child,
      builder: (Widget child) {
        return widget.useAnimation ? _buildBodyAnimation(child) : child;
      },
      belowBuilder: (targetOffset, targetSize) {
        return [
          //暗色背景widget动画
          MaskEvent(
            maskTriggerType: widget.maskTriggerType,
            onMask: widget.onMask,
            child: HighlightMaskAnimation(
              controller: _maskController!,
              maskColor: widget.maskColor,
              maskWidget: widget.maskWidget,
              usePenetrate: widget.usePenetrate,
              targetOffset: targetOffset,
              targetSize: targetSize,
              highlightBuilder: widget.highlightBuilder,
            ),
          ),
        ];
      },
    );
  }

  void beforeBuilder(
    Offset targetOffset,
    Size targetSize,
    Offset selfOffset,
    Size selfSize,
  ) {
    final screen = MediaQuery.of(context).size;

    //替换控件builder
    if (widget.replaceBuilder != null) {
      Widget replaceChildBuilder() {
        return widget.replaceBuilder!(
          targetOffset,
          targetSize,
          Offset(
            _targetRect?.left != null
                ? _targetRect!.left!
                : screen.width - ((_targetRect?.right ?? 0) + selfSize.width),
            _targetRect?.top != null
                ? _targetRect!.top!
                : screen.height -
                    ((_targetRect?.bottom ?? 0) + selfSize.height),
          ),
          selfSize,
        );
      }

      //必须要写在DialogScope的builder之外,保证在scalePointBuilder之前触发replaceBuilder
      _child = replaceChildBuilder();
      //保证controller能刷新replaceBuilder
      if (widget.child is DialogScope) {
        _child = DialogScope(
          controller: (widget.child as DialogScope).controller,
          builder: (context) => replaceChildBuilder(),
        );
      }
    }

    //缩放动画的缩放点
    if (widget.scalePointBuilder != null) {
      var halfWidth = selfSize.width / 2;
      var halfHeight = selfSize.height / 2;
      var scalePoint = widget.scalePointBuilder!(selfSize);
      var scaleDx = scalePoint.dx;
      var scaleDy = scalePoint.dy;
      var rateX = (scaleDx - halfWidth) / halfWidth;
      var rateY = (scaleDy - halfHeight) / halfHeight;
      _scaleAlignment = Alignment(rateX, rateY);
    }
  }

  Widget _buildBodyAnimation(Widget child) {
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!.call(
        _bodyController,
        child,
        _animationParam = AnimationParam(
          alignment: widget.alignment,
          animationTime: widget.animationTime,
        ),
      );
    }

    var type = widget.animationType;
    Widget fade = FadeAnimation(controller: _bodyController, child: child);
    Widget scale = ScaleAnimation(
      controller: _bodyController,
      alignment: _scaleAlignment ?? Alignment(0, 0),
      child: child,
    );
    Widget size = SizeAnimation(
      alignment: widget.alignment,
      controller: _bodyController,
      child: child,
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
        animation = size;
      }
    } else if (type == SmartAnimationType.centerScale_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animation = scale;
      } else {
        animation = size;
      }
    }

    return animation;
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_maskController == null) return;
    //over animation
    _maskController!.reverse();
    _bodyController.reverse();
    _animationParam?.onDismiss?.call();

    var awaitTime = _bodyController.duration ?? widget.animationTime;
    if (widget.useAnimation) {
      await Future.delayed(awaitTime);
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

class AttachDialogController extends BaseController {
  _AttachDialogWidgetState? _state;

  void _bind(_AttachDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    await _state?.dismiss();
  }
}
