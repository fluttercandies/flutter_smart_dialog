import 'dart:async';

import 'package:flutter/material.dart';

typedef SmartDialogVoidCallBack = void Function();

class SmartDialogView extends StatefulWidget {
  SmartDialogView({
    Key? key,
    required this.child,
    required this.onBgTap,
    required this.alignment,
    required this.isPenetrate,
    required this.animationDuration,
    required this.isUseAnimation,
    required this.isLoading,
    required this.maskColor,
    required this.clickBgDismiss,
  }) : super(key: key);

  ///内容widget
  final Widget child;

  ///点击背景
  final SmartDialogVoidCallBack onBgTap;

  ///内容控件方向
  final AlignmentGeometry alignment;

  ///是否穿透背景,交互背景之后控件
  final bool isPenetrate;

  ///动画时间
  final Duration animationDuration;

  ///是否使用动画
  final bool isUseAnimation;

  ///是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  ///仅仅针对中间位置的控件
  final bool isLoading;

  ///遮罩颜色
  final Color maskColor;

  ///点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  final bool clickBgDismiss;

  @override
  SmartDialogViewState createState() => SmartDialogViewState();
}

class SmartDialogViewState extends State<SmartDialogView>
    with SingleTickerProviderStateMixin {
  late double _opacity;

  late AnimationController _controller;

  //处理下内容widget动画放心
  Offset? _offset;

  @override
  void initState() {
    //处理背景动画和内容widget动画设置
    _opacity = widget.isUseAnimation ? 0.0 : 1.0;
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _controller.forward();
    _dealContentAnimate();

    //开启背景动画的效果
    Future.delayed(Duration(milliseconds: 10), () {
      _opacity = 1.0;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBg(children: [
      //暗色背景widget动画
      _buildBgAnimation(),

      //内容Widget动画
      Align(
        alignment: widget.alignment,
        child: widget.isUseAnimation ? _buildBodyAnimation() : widget.child,
      ),
    ]);
  }

  AnimatedOpacity _buildBgAnimation() {
    return AnimatedOpacity(
      duration: widget.animationDuration,
      curve: Curves.linear,
      opacity: _opacity,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (event) async {
          if (widget.clickBgDismiss) {
            widget.onBgTap();
          }
        },
        child: Container(
          color: widget.isPenetrate ? null : widget.maskColor,
        ),
      ),
    );
  }

  Widget _buildBodyAnimation() {
    return widget.alignment == Alignment.center
        //中间弹窗动画的使用需要分情况 渐隐和缩放俩种
        ? (widget.isLoading
            ? AnimatedOpacity(
                duration: widget.animationDuration,
                curve: Curves.linear,
                opacity: _opacity,
                child: widget.child,
              )
            : ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.linear,
                ),
                child: widget.child,
              ))
        //除了中间弹窗,其它的都使用位移动画
        : SlideTransition(
            position: Tween<Offset>(
              begin: _offset,
              end: Offset.zero,
            ).animate(_controller),
            child: widget.child,
          );
  }

  Widget _buildBg({required List<Widget> children}) {
    return Container(
      child: Stack(
        children: children,
      ),
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
    //背景结束动画
    setState(() {
      _opacity = 0.0;
    });

    //内容widget结束动画
    _controller.reverse();

    if (widget.isUseAnimation) {
      await Future.delayed(widget.animationDuration);
    }
  }

  @override
  void dispose() {
    //关闭资源
    _controller.dispose();
    super.dispose();
  }
}
