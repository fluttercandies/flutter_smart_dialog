import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/location.dart';

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.targetContext,
    required this.controller,
    required this.animationDuration,
    required this.isUseAnimation,
    required this.onBgTap,
    required this.alignment,
    required this.isPenetrate,
    required this.isLoading,
    required this.maskColor,
    required this.clickBgDismiss,
    this.maskWidget,
  }) : super(key: key);

  ///target context
  final BuildContext targetContext;

  /// 是否使用动画
  final bool isUseAnimation;

  ///动画时间
  final Duration animationDuration;

  final Widget child;

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

  /// 点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  final bool clickBgDismiss;

  @override
  _AttachDialogWidgetState createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with SingleTickerProviderStateMixin {
  late double _opacity;

  late AnimationController _controller;

  //target info
  RectInfo? _targetRect;
  late BuildContext _childContext;
  late Axis _axis;

  @override
  void initState() {
    //处理背景动画和内容widget动画设置
    _opacity = widget.isUseAnimation ? 0.0 : 1.0;
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _controller.forward();

    //开启背景动画的效果
    Future.delayed(Duration(milliseconds: 10), () {
      _opacity = 1.0;
      if (mounted) setState(() {});
    });

    //bind controller
    widget.controller.bind(this);

    //target info
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) _handleLocation();
    });
    _axis = Axis.vertical;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AttachDialogWidget oldWidget) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) _handleLocation();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(
        onPointerUp: widget.clickBgDismiss ? widget.onBgTap : null,
        child: (widget.maskWidget != null && !widget.isPenetrate)
            ? widget.maskWidget
            : Container(color: widget.isPenetrate ? null : widget.maskColor),
      ),

      //get child size
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: Builder(builder: (context) {
          _childContext = context;
          return Opacity(opacity: 0, child: widget.child);
        }),
      ),

      //内容Widget动画
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.isUseAnimation
            ? _buildBodyAnimation(widget.child)
            : widget.child,
      ),
    ]);
  }

  AnimatedOpacity _buildBgAnimation({
    required void Function()? onPointerUp,
    required Widget? child,
  }) {
    return AnimatedOpacity(
      duration: widget.animationDuration,
      curve: Curves.linear,
      opacity: _opacity,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (event) => onPointerUp?.call(),
        child: child,
      ),
    );
  }

  Widget _buildBodyAnimation(Widget child) {
    var transition = widget.alignment == Alignment.center
        //中间弹窗动画的使用需要分情况 渐隐和缩放俩种
        ? ScaleTransition(
            scale: CurvedAnimation(parent: _controller, curve: Curves.linear),
            child: child,
          )
        //除了中间弹窗,其它的都使用位移动画
        : SizeTransition(axis: _axis, sizeFactor: _controller, child: child);

    return widget.isLoading
        ? AnimatedOpacity(
            duration: widget.animationDuration,
            curve: Curves.linear,
            opacity: _opacity,
            child: child,
          )
        : transition;
    ;
  }

  ///处理下内容widget动画方向
  void _handleLocation() {
    _axis = Axis.vertical;
    final alignment = widget.alignment;
    final renderBox = widget.targetContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screen = MediaQuery.of(widget.targetContext).size;
    final childSize = (_childContext.findRenderObject() as RenderBox).size;

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
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    //背景结束动画
    _opacity = 0.0;
    if (mounted) setState(() {});

    //内容widget结束动画
    _controller.reverse();

    if (widget.isUseAnimation) {
      await Future.delayed(widget.animationDuration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AttachDialogController extends BaseController {
  _AttachDialogWidgetState? _state;

  void bind(_AttachDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    await _state?.dismiss();
    _state = null;
  }
}
