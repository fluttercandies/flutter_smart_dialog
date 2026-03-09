import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

class ToastHelper extends StatefulWidget {
  const ToastHelper({
    Key? key,
    required this.consumeEvent,
    required this.child,
  }) : super(key: key);

  final bool consumeEvent;

  final Widget child;

  @override
  State<ToastHelper> createState() => _ToastHelperState();
}

class _ToastHelperState extends State<ToastHelper> with WidgetsBindingObserver {
  //solve problem of keyboard shelter toast
  double _keyboardHeight = 0;
  BuildContext? _childContext;

  //offset size
  Offset? selfOffset;
  Size? selfSize;

  @override
  void initState() {
    widgetsBinding.addObserver(this);

    ViewUtils.addSafeUse(() {
      if (!mounted || !_updateSelfInfo()) {
        return;
      }
      _dealKeyboard();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var child = Builder(builder: (context) {
      _childContext = context;
      return widget.child;
    });

    return Container(
      margin: EdgeInsets.only(bottom: _keyboardHeight),
      child: widget.consumeEvent ? child : IgnorePointer(child: child),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _dealKeyboard();
  }

  @override
  void dispose() {
    widgetsBinding.removeObserver(this);
    super.dispose();
  }

  void _dealKeyboard() {
    ViewUtils.addSafeUse(() {
      if (!mounted || !_updateSelfInfo()) {
        return;
      }

      var screen = MediaQuery.of(context).size;
      var childToBottom = screen.height - (selfOffset!.dy + selfSize!.height);
      var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (childToBottom < 0) {
        _updateKeyboardHeight(keyboardHeight);
        return;
      }
      if (childToBottom - keyboardHeight > -30) {
        return;
      }
      _updateKeyboardHeight(keyboardHeight - childToBottom);
    });
  }

  bool _updateSelfInfo() {
    if (selfOffset != null) {
      return true;
    }

    final childContext = _childContext;
    if (!(childContext?.mounted ?? false)) {
      selfOffset = null;
      selfSize = null;
      return false;
    }

    final renderObject = childContext!.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      selfOffset = null;
      selfSize = null;
      return false;
    }

    try {
      selfOffset = renderObject.localToGlobal(Offset.zero);
      selfSize = renderObject.size;
      return true;
    } catch (_) {
      selfOffset = null;
      selfSize = null;
      return false;
    }
  }

  void _updateKeyboardHeight(double value) {
    if (_keyboardHeight == value) {
      return;
    }
    _keyboardHeight = value;
    setState(() {});
  }
}
