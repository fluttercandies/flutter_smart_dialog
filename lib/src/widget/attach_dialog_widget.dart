import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/location.dart';

typedef SmartHighlightBuilder = Positioned Function(
    Offset targetOffset, Size targetSize);

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.targetContext,
    required this.target,
    required this.controller,
    required this.animationDuration,
    required this.isUseAnimation,
    required this.onBgTap,
    required this.alignment,
    required this.isPenetrate,
    required this.isLoading,
    required this.maskColor,
    required this.clickBgDismiss,
    required this.highlight,
    required this.highlightBuilder,
    this.maskWidget,
  }) : super(key: key);

  ///target context
  final BuildContext? targetContext;

  final Offset? target;

  /// 是否使用动画
  final bool isUseAnimation;

  ///动画时间
  final Duration animationDuration;

  ///自定义的主体布局
  final Widget child;

  ///widget controller
  final AttachDialogController controller;

  /// 点击背景
  final VoidCallback onBgTap;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool isPenetrate;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final bool isLoading;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 溶解遮罩,设置高亮位置
  final Positioned highlight;
  final SmartHighlightBuilder? highlightBuilder;

  /// 点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  final bool clickBgDismiss;

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
  late Axis _axis;
  late double _postFrameOpacity;

  //refuse operation during dispose
  bool _closing = false;

  //offset size
  late Offset targetOffset;
  late Size targetSize;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  void _resetState() {
    var duration = widget.animationDuration;
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
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
    var child = Opacity(opacity: _postFrameOpacity, child: widget.child);
    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(
        onPointerUp: widget.clickBgDismiss ? widget.onBgTap : null,
        child: (widget.maskWidget != null && !widget.isPenetrate)
            ? widget.maskWidget
            : widget.isPenetrate
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
                      widget.highlightBuilder == null
                          ? widget.highlight
                          : widget.highlightBuilder!(targetOffset, targetSize),
                    ]),
                  ),
      ),

      //CustomSingleChildLayout 和 SizeTransition 占位面积冲突
      //使用SizeTransition位移动画，不适合使用CustomSingleChildLayout
      //只能使用折中的方式获取子控件大小
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: Center(
          child: Builder(builder: (context) {
            _childContext = context;
            return Opacity(opacity: 0, child: widget.child);
          }),
        ),
      ),

      //内容Widget动画
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.isUseAnimation ? _buildBodyAnimation(child) : child,
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
    var transition = widget.alignment == Alignment.center
        //中间弹窗动画使用缩放
        ? ScaleTransition(scale: animation, child: child)
        //其它的都使用位移动画
        : SizeTransition(axis: _axis, sizeFactor: _ctrlBody, child: child);

    return widget.isLoading
        ? FadeTransition(opacity: animation, child: child)
        : transition;
  }

  ///处理下动画方向及其位置
  void _handleAnimatedAndLocation() {
    _axis = Axis.vertical;
    final alignment = widget.alignment;
    var offset = targetOffset;
    var size = targetSize;
    final screen = MediaQuery.of(context).size;
    final childSize = (_childContext!.findRenderObject() as RenderBox).size;

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

    //第一帧后恢复透明度
    _postFrameOpacity = 1;
    setState(() {});
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_closing) return;

    _closing = true;
    //over animation
    _ctrlBg?.reverse();
    _ctrlBody.reverse();

    if (widget.isUseAnimation) {
      await Future.delayed(widget.animationDuration);
    }
  }

  @override
  void dispose() {
    _ctrlBg?.dispose();
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
    await _state?.dismiss();
    _state = null;
  }
}
