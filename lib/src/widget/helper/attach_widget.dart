import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../util/view_utils.dart';
import '../attach_dialog_widget.dart';

typedef AttachBuilder = Widget Function(Widget child);

typedef BeforeBuilder = Widget Function(
  Offset targetOffset,
  Size targetSize,
  Offset selfOffset,
  Size selfSize,
);

typedef CoverBuilder = List<Widget> Function(
  Offset targetOffset,
  Size targetSize,
);

class AttachWidget extends StatefulWidget {
  const AttachWidget({
    Key? key,
    required this.targetContext,
    required this.targetBuilder,
    required this.beforeBuilder,
    required this.alignment,
    required this.originChild,
    required this.builder,
    this.belowBuilder,
    this.aboveBuilder,
  }) : super(key: key);

  /// 目标widget
  final BuildContext? targetContext;

  /// 自定义坐标点
  final TargetBuilder? targetBuilder;

  final BeforeBuilder? beforeBuilder;

  final AlignmentGeometry alignment;

  final Widget originChild;

  final AttachBuilder builder;
  final CoverBuilder? belowBuilder;
  final CoverBuilder? aboveBuilder;

  @override
  State<AttachWidget> createState() => _AttachWidgetState();
}

class _AttachWidgetState extends State<AttachWidget> {
  late double _postFrameOpacity;

  //offset size
  late Offset targetOffset;
  late Size targetSize;

  //target info
  RectInfo? _targetRect;
  BuildContext? _childContext;
  late Widget _originChild;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AttachWidget oldWidget) {
    if (oldWidget.originChild != widget.originChild ||
        oldWidget.targetContext != widget.targetContext ||
        oldWidget.targetBuilder != widget.targetBuilder) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var child = AdaptBuilder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: _originChild);
    });

    List<Widget> below = widget.belowBuilder?.call(targetOffset, targetSize) ?? [];
    List<Widget> above = widget.aboveBuilder?.call(targetOffset, targetSize) ?? [];
    return Stack(children: [
      //blow
      for (var belowWidget in below) belowWidget,

      //target
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.builder(child),
      ),

      //above
      for (var aboveWidget in above) aboveWidget,
    ]);
  }

  void _resetState() {
    _originChild = widget.originChild;
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

    ViewUtils.addSafeUse(() {
      if (mounted) _handleLocation();
    });
  }

  /// 处理: 方向及其位置
  void _handleLocation() {
    final selfSize = (_childContext!.findRenderObject() as RenderBox).size;
    final screen = MediaQuery.of(context).size;

    //动画方向及其位置
    final alignment = widget.alignment;

    if (alignment == Alignment.topLeft) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx + _calculateDx(alignment, selfSize),
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
        left: targetOffset.dx + targetSize.width + _calculateDx(alignment, selfSize),
        fixedVertical: true,
      );
    } else if (alignment == Alignment.centerLeft) {
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
      _targetRect = _adjustReactInfo(
        left: targetOffset.dx + targetSize.width,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.bottomLeft) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx + _calculateDx(alignment, selfSize),
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
        left: targetOffset.dx + targetSize.width + _calculateDx(alignment, selfSize),
        fixedVertical: true,
      );
    }

    if (widget.beforeBuilder != null) {
      _originChild = widget.beforeBuilder!.call(
        targetOffset,
        targetSize,
        Offset(
          _targetRect?.left != null
              ? _targetRect!.left!
              : screen.width - ((_targetRect?.right ?? 0) + selfSize.width),
          _targetRect?.top != null
              ? _targetRect!.top!
              : screen.height - ((_targetRect?.bottom ?? 0) + selfSize.height),
        ),
        selfSize,
      );
    }

    //第一帧后恢复透明度,同时重置位置信息
    _postFrameOpacity = 1;
    setState(() {});
  }

  /// 计算attach alignment类型的偏移量
  double _calculateDx(AlignmentGeometry alignment, Size selfSize) {
    double offset = 0;
    var type = SmartDialog.config.attach.attachAlignmentType;

    if (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) {
      if (type == SmartAttachAlignmentType.inside) {
        offset = 0;
      } else if (type == SmartAttachAlignmentType.outside) {
        offset = -selfSize.width;
      } else {
        offset = -(selfSize.width / 2);
      }
    } else if (alignment == Alignment.topRight || alignment == Alignment.bottomRight) {
      if (type == SmartAttachAlignmentType.inside) {
        offset = -selfSize.width;
      } else if (type == SmartAttachAlignmentType.outside) {
        offset = 0;
      } else {
        offset = -(selfSize.width / 2);
      }
    }

    return offset;
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
}

class AdaptBuilder extends StatelessWidget {
  const AdaptBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          constraints: BoxConstraints(maxWidth: size.width),
          child: builder(context),
        ),
      ]),
    ]);
  }
}

class RectInfo {
  RectInfo({this.left, this.right, this.bottom, this.top});

  double? left;
  double? right;
  double? top;
  double? bottom;
}
