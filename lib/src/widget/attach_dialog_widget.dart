import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/location.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

import '../config/enum_config.dart';

typedef HighlightBuilder = Positioned Function(
  Offset targetOffset,
  Size targetSize,
);

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.targetContext,
    required this.target,
    required this.controller,
    required this.animationTime,
    required this.useAnimation,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationType,
    required this.scalePoint,
    required this.maskColor,
    required this.highlightBuilder,
    required this.maskWidget,
  }) : super(key: key);

  ///target context
  final BuildContext? targetContext;

  final Offset? target;

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

  /// 缩放动画的缩放点
  final Offset? scalePoint;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 溶解遮罩,设置高亮位置
  final HighlightBuilder highlightBuilder;

  @override
  _AttachDialogWidgetState createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with TickerProviderStateMixin {
  AnimationController? _ctrlBg;
  late AnimationController _ctrlBody;

  //target info
  RectInfo? _targetRect;
  BuildContext? _childContext;
  Alignment? _scaleAlignment;
  late Axis _axis;
  late double _postFrameOpacity;

  //offset size
  late Offset targetOffset;
  late Size targetSize;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  void _resetState() {
    var duration = widget.animationTime;
    if (_ctrlBg == null) {
      _ctrlBg = AnimationController(vsync: this, duration: duration);
      _ctrlBody = AnimationController(vsync: this, duration: duration);
      _ctrlBg?.forward();
      _ctrlBody.forward();
    } else {
      _ctrlBg!.duration = duration;
      _ctrlBody.duration = duration;

      _ctrlBody.value = 0;
      _ctrlBody.forward();
    }

    //target info
    _postFrameOpacity = 0;
    if (widget.targetContext != null) {
      final renderBox = widget.targetContext!.findRenderObject() as RenderBox;
      targetOffset = renderBox.localToGlobal(Offset.zero);
      targetSize = renderBox.size;
    }
    if (widget.target != null) {
      targetOffset = widget.target!;
      targetSize = Size.zero;
    }
    ViewUtils.addPostFrameCallback((timeStamp) {
      if (mounted) _handleAnimatedAndLocation();
    });
    _axis = Axis.vertical;

    //bind controller
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant AttachDialogWidget oldWidget) {
    if (oldWidget.child != widget.child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    //CustomSingleChildLayout 和 SizeTransition 占位面积冲突
    //使用SizeTransition位移动画，不适合使用CustomSingleChildLayout
    //也可使用该方式获取子控件大小
    var child = Builder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: widget.child);
    });

    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(
        onPointerUp: widget.onMask,
        child: (widget.maskWidget != null && !widget.usePenetrate)
            ? widget.maskWidget
            : widget.usePenetrate
                ? Container()
                : ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      // mask color
                      widget.maskColor,
                      BlendMode.srcOut,
                    ),
                    child: Stack(children: [
                      Container(
                        decoration: BoxDecoration(
                          // any color
                          color: Colors.white,
                          backgroundBlendMode: BlendMode.dstOut,
                        ),
                      ),

                      //dissolve mask, highlight location
                      widget.highlightBuilder(targetOffset, targetSize)
                    ]),
                  ),
      ),

      //内容Widget动画
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.useAnimation ? _buildBodyAnimation(child) : child,
      ),
    ]);
  }

  Widget _buildBgAnimation({
    required void Function()? onPointerUp,
    required Widget? child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrlBg!, curve: Curves.linear),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (event) => onPointerUp?.call(),
        child: child,
      ),
    );
  }

  Widget _buildBodyAnimation(Widget child) {
    var animation = CurvedAnimation(parent: _ctrlBody, curve: Curves.linear);
    var type = widget.animationType;
    Widget animationWidget = FadeTransition(opacity: animation, child: child);

    //select different animation
    if (type == SmartAnimationType.fade) {
      animationWidget = FadeTransition(opacity: animation, child: child);
    } else if (type == SmartAnimationType.scale) {
      animationWidget = ScaleTransition(
        alignment: _scaleAlignment ?? Alignment(0, 0),
        scale: animation,
        child: child,
      );
    } else if (type == SmartAnimationType.centerFade_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animationWidget = FadeTransition(opacity: animation, child: child);
      } else {
        animationWidget = SizeTransition(
          axis: _axis,
          sizeFactor: _ctrlBody,
          child: child,
        );
      }
    } else if (type == SmartAnimationType.centerScale_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animationWidget = ScaleTransition(
          alignment: _scaleAlignment ?? Alignment(0, 0),
          scale: animation,
          child: child,
        );
      } else {
        animationWidget = SizeTransition(
          axis: _axis,
          sizeFactor: _ctrlBody,
          child: child,
        );
      }
    }

    return animationWidget;
  }

  /// 处理: 动画方向及其位置, 缩放动画的缩放点
  void _handleAnimatedAndLocation() {
    final childSize = (_childContext!.findRenderObject() as RenderBox).size;

    //动画方向及其位置
    _axis = Axis.vertical;
    final alignment = widget.alignment;
    var offset = targetOffset;
    var size = targetSize;
    final screen = MediaQuery.of(context).size;
    if (alignment == Alignment.topLeft) {
      _targetRect = RectInfo(
        bottom: screen.height - offset.dy,
        left: max(offset.dx - childSize.width / 2, 0),
      );
    } else if (alignment == Alignment.topCenter) {
      _targetRect = RectInfo(
        bottom: screen.height - offset.dy,
        left: max(offset.dx + size.width / 2 - childSize.width / 2, 0),
      );
    } else if (alignment == Alignment.topRight) {
      _targetRect = RectInfo(
        bottom: screen.height - offset.dy,
        right: max(
            screen.width - (offset.dx + size.width + childSize.width / 2), 0),
      );
    } else if (alignment == Alignment.centerLeft) {
      _axis = Axis.horizontal;
      _targetRect = RectInfo(
        right: screen.width - offset.dx,
        top: max(offset.dy + size.height / 2 - childSize.height / 2, 0),
      );
    } else if (alignment == Alignment.center) {
      _targetRect = RectInfo(
        left: max(offset.dx + size.width / 2 - childSize.width / 2, 0),
        top: max(offset.dy + size.height / 2 - childSize.height / 2, 0),
      );
    } else if (alignment == Alignment.centerRight) {
      _axis = Axis.horizontal;
      _targetRect = RectInfo(
        left: offset.dx + size.width,
        top: max(offset.dy + size.height / 2 - childSize.height / 2, 0),
      );
    } else if (alignment == Alignment.bottomLeft) {
      _targetRect = RectInfo(
        top: offset.dy + size.height,
        left: max(offset.dx - childSize.width / 2, 0),
      );
    } else if (alignment == Alignment.bottomCenter) {
      _targetRect = RectInfo(
        top: offset.dy + size.height,
        left: max(offset.dx + size.width / 2 - childSize.width / 2, 0),
      );
    } else if (alignment == Alignment.bottomRight) {
      _targetRect = RectInfo(
        top: offset.dy + size.height,
        right: max(
            screen.width - (offset.dx + size.width + childSize.width / 2), 0),
      );
    }

    //缩放动画的缩放点
    if (widget.scalePoint != null) {
      var halfWidth = childSize.width / 2;
      var halfHeight = childSize.height / 2;
      var scaleDx = widget.scalePoint!.dx;
      var scaleDy = widget.scalePoint!.dy;
      var rateX = (scaleDx - halfWidth) / halfWidth;
      var rateY = (scaleDy - halfHeight) / halfHeight;
      _scaleAlignment = Alignment(rateX, rateY);
    }

    //第一帧后恢复透明度,同时重置位置信息
    _postFrameOpacity = 1;
    setState(() {});
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_ctrlBg == null) return;
    //over animation
    _ctrlBg!.reverse();
    _ctrlBody.reverse();

    if (widget.useAnimation) {
      await Future.delayed(widget.animationTime);
    }
  }

  @override
  void dispose() {
    _ctrlBg?.dispose();
    _ctrlBg = null;
    _ctrlBody.dispose();
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
