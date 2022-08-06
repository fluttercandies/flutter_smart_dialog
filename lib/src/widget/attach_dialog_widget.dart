import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/data/location.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/dialog_scope.dart';

import '../config/enum_config.dart';

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

  late Widget _child;

  bool _maskTrigger = false;

  @override
  void initState() {
    _child = widget.child;

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
    if (widget.targetBuilder != null) {
      targetOffset = widget.targetContext != null
          ? widget.targetBuilder!(
              targetOffset,
              Size(targetSize.width, targetSize.height),
            )
          : widget.targetBuilder!(Offset.zero, Size.zero);
      targetSize = widget.targetContext != null ? targetSize : Size.zero;
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
    if (oldWidget.child != _child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    //CustomSingleChildLayout 和 SizeTransition 占位面积冲突
    //使用SizeTransition位移动画，不适合使用CustomSingleChildLayout
    //也可使用该方式获取子控件大小
    var child = AdaptBuilder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: _child);
    });

    //handle mask
    late Widget maskWidget;
    if (widget.usePenetrate) {
      maskWidget = Container();
    } else if (widget.maskWidget != null) {
      maskWidget = widget.maskWidget!;
    } else {
      maskWidget = ColorFiltered(
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
      );
    }

    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(onMask: widget.onMask, child: maskWidget),

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
    required void Function()? onMask,
    required Widget? child,
  }) {
    Function()? onPointerDown;
    Function()? onPointerMove;
    Function()? onPointerUp;
    if (widget.maskTriggerType == SmartMaskTriggerType.down) {
      onPointerDown = onMask;
    } else if (widget.maskTriggerType == SmartMaskTriggerType.move) {
      onPointerMove = onMask;
    } else {
      onPointerUp = onMask;
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrlBg!, curve: Curves.linear),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          onPointerDown?.call();
          if (onPointerDown != null) _maskTrigger = true;
        },
        onPointerMove: (event) {
          if (!_maskTrigger) onPointerMove?.call();
          if (onPointerMove != null) _maskTrigger = true;
        },
        onPointerUp: (event) {
          onPointerUp?.call();
          if (onPointerUp == null && !_maskTrigger) onMask?.call();
          _maskTrigger = false;
        },
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
    final selfSize = (_childContext!.findRenderObject() as RenderBox).size;
    final screen = MediaQuery.of(context).size;

    //动画方向及其位置
    _axis = Axis.vertical;
    final alignment = widget.alignment;

    if (alignment == Alignment.topLeft) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.topCenter) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.topRight) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx + targetSize.width - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.centerLeft) {
      _axis = Axis.horizontal;
      _targetRect = _adjustReactInfo(
        right: screen.width - targetOffset.dx,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.center) {
      _targetRect = _adjustReactInfo(
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.centerRight) {
      _axis = Axis.horizontal;
      _targetRect = _adjustReactInfo(
        left: targetOffset.dx + targetSize.width,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.bottomLeft) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.bottomCenter) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.bottomRight) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx + targetSize.width - selfSize.width / 2,
        fixedVertical: true,
      );
    }

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

    //第一帧后恢复透明度,同时重置位置信息
    _postFrameOpacity = 1;
    setState(() {});
  }

  RectInfo _adjustReactInfo({
    double? left,
    double? right,
    double? top,
    double? bottom,
    bool fixedHorizontal = false,
    bool fixedVertical = false,
  }) {
    final childSize = (_childContext!.findRenderObject() as RenderBox).size;
    final screen = MediaQuery.of(context).size;
    var rectInfo = RectInfo(left: left, right: right, top: top, bottom: bottom);

    //处理左右边界问题
    if (!fixedHorizontal && left != null) {
      if (left < 0) {
        rectInfo.left = 0;
        rectInfo.right = null;
      } else {
        var rightEdge = screen.width - left - childSize.width;
        if (rightEdge < 0) {
          rectInfo.left = null;
          rectInfo.right = 0;
        }
      }
    }

    //处理上下边界问题
    if (!fixedVertical && top != null) {
      if (top < 0) {
        rectInfo.top = 0;
        rectInfo.bottom = null;
      } else {
        var bottomEdge = screen.height - top - childSize.height;
        if (bottomEdge < 0) {
          rectInfo.top = null;
          rectInfo.bottom = 0;
        }
      }
    }

    return rectInfo;
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

class AdaptBuilder extends StatelessWidget {
  const AdaptBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Column(mainAxisSize: MainAxisSize.min, children: [builder(context)]),
    ]);
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
