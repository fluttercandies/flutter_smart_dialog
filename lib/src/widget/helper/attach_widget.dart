import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

import '../attach_dialog_widget.dart';

typedef AttachBuilder = Widget Function(
  Widget child,
  AttachAdjustParam? adjustParam,
);

typedef BeforeBuilder = AttachAdjustParam Function(
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

  /// target widget
  final BuildContext? targetContext;

  /// custom target point
  final TargetBuilder? targetBuilder;

  final BeforeBuilder beforeBuilder;

  final Alignment alignment;

  final Widget originChild;

  final AttachBuilder builder;
  final CoverBuilder? belowBuilder;
  final CoverBuilder? aboveBuilder;

  @override
  State<AttachWidget> createState() => _AttachWidgetState();
}

class _AttachWidgetState extends State<AttachWidget>
    with WidgetsBindingObserver {
  late double _postFrameOpacity;

  // offset & size
  Offset targetOffset = Offset.zero;
  Size targetSize = Size.zero;

  // target info
  RectInfo? _targetRect;
  BuildContext? _childContext;
  late Widget _originChild;

  late Alignment _alignment;
  AttachAdjustParam? _adjustParam;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _alignment = widget.alignment;
    _resetState();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttachWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.originChild != widget.originChild ||
        oldWidget.targetContext != widget.targetContext ||
        oldWidget.targetBuilder != widget.targetBuilder) {
      _resetState();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // The latency threshold is approximately 8 milliseconds.
    Future.delayed(const Duration(milliseconds: 30), () {
      if (!mounted) {
        return;
      }
      _resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    var child = AdaptBuilder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: _originChild);
    });

    List<Widget> below =
        widget.belowBuilder?.call(targetOffset, targetSize) ?? [];
    List<Widget> above =
        widget.aboveBuilder?.call(targetOffset, targetSize) ?? [];
    return Stack(children: [
      for (var belowWidget in below) belowWidget,
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.builder(child, _adjustParam),
      ),
      for (var aboveWidget in above) aboveWidget,
    ]);
  }

  void _resetState() {
    if (!mounted) {
      return;
    }

    _originChild = widget.originChild;
    _postFrameOpacity = 0;
    _targetRect = null;

    final hasTargetInfo = _tryUpdateTargetInfo();
    if (widget.targetBuilder != null) {
      final customOffset = widget.targetBuilder!(
        targetOffset,
        Size(targetSize.width, targetSize.height),
      );
      if (_isValidOffset(customOffset)) {
        targetOffset = customOffset;
      }

      // targetBuilder can work without targetContext.
      if (widget.targetContext == null && !hasTargetInfo) {
        final fallbackOffset = widget.targetBuilder!(Offset.zero, Size.zero);
        targetOffset =
            _isValidOffset(fallbackOffset) ? fallbackOffset : Offset.zero;
        targetSize = Size.zero;
      }
    }

    // targetContext exists but currently unavailable (inactive/not laid out).
    if (!hasTargetInfo &&
        widget.targetContext != null &&
        widget.targetBuilder == null) {
      return;
    }

    ViewUtils.addSafeUse(() {
      if (mounted) {
        _handleLocation();
      }
    });
  }

  void _handleLocation() {
    final selfRenderBox = _safeRenderBox(_childContext);
    if (selfRenderBox == null ||
        !_isValidOffset(targetOffset) ||
        !_isValidSize(targetSize)) {
      return;
    }

    final selfSize = selfRenderBox.size;
    final screen = MediaQuery.of(context).size;
    if (!_isValidSize(selfSize) || !_isValidSize(screen)) {
      return;
    }

    final alignment = _alignment;

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
        left: targetOffset.dx +
            targetSize.width +
            _calculateDx(alignment, selfSize),
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
        left: targetOffset.dx +
            targetSize.width +
            _calculateDx(alignment, selfSize),
        fixedVertical: true,
      );
    }

    AttachAdjustParam adjustParam = _adjustParam = widget.beforeBuilder.call(
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
    _originChild = adjustParam.builder?.call(context) ?? _originChild;
    if (_alignment != adjustParam.alignment) {
      _alignment = adjustParam.alignment ?? Alignment.center;
      _handleLocation();
      return;
    }

    _postFrameOpacity = 1;
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  double _calculateDx(Alignment alignment, Size selfSize) {
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
    } else if (alignment == Alignment.topRight ||
        alignment == Alignment.bottomRight) {
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
    final childRenderBox = _safeRenderBox(_childContext);
    final screen = MediaQuery.of(context).size;
    var rectInfo = RectInfo(left: left, right: right, top: top, bottom: bottom);
    if (childRenderBox == null || !_isValidSize(screen)) {
      return rectInfo;
    }

    final childSize = childRenderBox.size;
    if (!_isValidSize(childSize)) {
      return rectInfo;
    }

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

  bool _tryUpdateTargetInfo() {
    final renderBox = _safeRenderBox(widget.targetContext);
    if (renderBox == null) {
      return false;
    }

    try {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      if (!_isValidOffset(offset) || !_isValidSize(size)) {
        return false;
      }
      targetOffset = offset;
      targetSize = size;
      return true;
    } catch (_) {
      return false;
    }
  }

  RenderBox? _safeRenderBox(BuildContext? context) {
    if (context == null) {
      return null;
    }

    try {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox &&
          renderObject.attached &&
          renderObject.hasSize) {
        return renderObject;
      }
    } catch (_) {}
    return null;
  }

  bool _isValidOffset(Offset offset) {
    return offset.dx.isFinite && offset.dy.isFinite;
  }

  bool _isValidSize(Size size) {
    return size.width.isFinite && size.height.isFinite;
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
