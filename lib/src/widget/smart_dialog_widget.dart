import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';

class SmartDialogWidget extends StatefulWidget {
  SmartDialogWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.onBgTap,
    required this.alignment,
    required this.isPenetrate,
    required this.animationDuration,
    required this.isUseAnimation,
    required this.isLoading,
    required this.maskColor,
    required this.clickBgDismiss,
    this.maskWidget,
  }) : super(key: key);

  /// 内容widget
  final Widget child;

  ///widget controller
  final SmartDialogController controller;

  /// 点击背景
  final VoidCallback onBgTap;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool isPenetrate;

  /// 动画时间
  final Duration animationDuration;

  /// 是否使用动画
  final bool isUseAnimation;

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
  _SmartDialogWidgetState createState() => _SmartDialogWidgetState();
}

class _SmartDialogWidgetState extends State<SmartDialogWidget>
    with TickerProviderStateMixin {
  AnimationController? _ctrlBg;
  late AnimationController _ctrlBody;
  Offset? _offset;

  //refuse operation during dispose
  bool _closing = false;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  void _resetState() {
    _dealContentAnimate();

    var duration = widget.animationDuration;
    if (_ctrlBg == null) {
      _ctrlBg = AnimationController(vsync: this, duration: duration);
      _ctrlBody = AnimationController(vsync: this, duration: duration);
      _ctrlBg!.forward();
      _ctrlBody.forward();
    } else {
      _ctrlBg!.duration = duration;
      _ctrlBody.duration = duration;

      _ctrlBody.value = 0;
      _ctrlBody.forward();
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
      _buildBgAnimation(
        onPointerUp: widget.clickBgDismiss ? widget.onBgTap : null,
        child: (widget.maskWidget != null && !widget.isPenetrate)
            ? widget.maskWidget
            : Container(color: widget.isPenetrate ? null : widget.maskColor),
      ),

      //内容Widget动画
      Container(
        alignment: widget.alignment,
        child: widget.isUseAnimation ? _buildBodyAnimation() : widget.child,
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

  Widget _buildBodyAnimation() {
    var animation = CurvedAnimation(parent: _ctrlBody, curve: Curves.linear);
    var centerTransition = widget.isLoading
        ? FadeTransition(opacity: animation, child: widget.child)
        : ScaleTransition(scale: animation, child: widget.child);

    return widget.alignment == Alignment.center
        //中间弹窗动画的使用需要分情况 渐隐和缩放俩种
        ? centerTransition
        //除了中间弹窗,其它的都使用位移动画
        : SlideTransition(
            position: Tween<Offset>(
              begin: _offset,
              end: Offset.zero,
            ).animate(_ctrlBody),
            child: widget.child,
          );
  }

  ///处理下内容widget动画方向
  void _dealContentAnimate() {
    AlignmentGeometry? alignment = widget.alignment;
    _offset = Offset(0, 0);

    if (alignment == Alignment.bottomCenter ||
        alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomRight) {
      //靠下
      _offset = Offset(0, 1);
    } else if (alignment == Alignment.topCenter ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.topRight) {
      //靠上
      _offset = Offset(0, -1);
    } else if (alignment == Alignment.centerLeft) {
      //靠左
      _offset = Offset(-1, 0);
    } else if (alignment == Alignment.centerRight) {
      //靠右
      _offset = Offset(1, 0);
    } else {
      //居中使用缩放动画,空结构体,不需要操作
    }
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_closing) return;

    _closing = true;
    //结束动画
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

class SmartDialogController extends BaseController {
  _SmartDialogWidgetState? _state;

  void _bind(_SmartDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    await _state?.dismiss();
    _state = null;
  }
}
