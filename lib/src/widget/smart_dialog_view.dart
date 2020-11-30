import 'dart:async';

import 'package:flutter/material.dart';

typedef SmartDialogVoidCallBack = void Function();

class SmartDialogView extends StatefulWidget {
  SmartDialogView({
    Key key,
    @required this.child,
    this.onBgTap,
    this.alignment = Alignment.bottomCenter,
    this.isPenetrate = true,
    this.animationDuration = const Duration(milliseconds: 260),
    this.isUseAnimation = false,
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

  @override
  SmartDialogViewState createState() => SmartDialogViewState();
}

class SmartDialogViewState extends State<SmartDialogView>
    with SingleTickerProviderStateMixin {
  double _opacity;

  AnimationController _controller;

  //处理下内容widget动画放心
  Offset _offset;

  @override
  void initState() {
    //处理背景动画
    _opacity = widget.isUseAnimation ? 0.0 : 1.0;
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    //处理内容widget动画
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _controller.forward();
    _dealContentAnimate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBg(children: [
      //背景
      AnimatedOpacity(
        duration: widget.animationDuration,
        curve: Curves.linear,
        opacity: _opacity,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerUp: (event) async {
            if (widget.onBgTap != null) {
              widget.onBgTap();
            }
          },
          child: Container(
            color: widget.isPenetrate ? null : Colors.black.withOpacity(0.3),
          ),
        ),
      ),

      //内容Widget
      Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {},
        child: Align(
          alignment: widget.alignment,
          child: widget.isUseAnimation
              //是否使用动画
              ? (widget.alignment == Alignment.center
                  //中间弹窗是否使用缩放动画
                  ? ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.linear,
                      ),
                      child: widget.child,
                    )
                  //除了中间弹窗,其它的都使用位移动画
                  : SlideTransition(
                      position: Tween<Offset>(
                        begin: _offset,
                        end: Offset.zero,
                      ).animate(_controller),
                      child: widget.child,
                    ))
              : widget.child,
        ),
      ),
    ]);
  }

  Widget _buildBg({List<Widget> children}) {
    return Container(
      child: Stack(
        children: children,
      ),
    );
  }

  //处理下内容widget动画方向
  void _dealContentAnimate() {
    AlignmentGeometry alignment = widget.alignment;
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
      //居中使用缩放动画
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
