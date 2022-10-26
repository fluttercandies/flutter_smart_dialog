import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

class ToastHelper extends StatefulWidget {
  ToastHelper({
    Key? key,
    required this.consumeEvent,
    required this.child,
  }) : super(key: key);

  final bool consumeEvent;

  final Widget child;

  @override
  _ToastHelperState createState() => _ToastHelperState();
}

class _ToastHelperState extends State<ToastHelper> with WidgetsBindingObserver {
  //solve problem of keyboard shelter toast
  double _keyboardHeight = 0;
  late double _postFrameOpacity;
  BuildContext? _childContext;

  //offset size
  Offset? selfOffset;
  Size? selfSize;

  @override
  void initState() {
    widgetsBinding.addObserver(this);

    _postFrameOpacity = 0;
    ViewUtils.addSafeUse(() {
      if (!mounted) return;

      final renderBox = _childContext!.findRenderObject() as RenderBox;
      selfOffset = renderBox.localToGlobal(Offset.zero);
      selfSize = renderBox.size;
      _postFrameOpacity = 1;
      setState(() {});
      _dealKeyboard();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var child = Builder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: widget.child);
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
      if (!mounted || selfOffset == null || selfSize == null) return;

      var screen = MediaQuery.of(context).size;
      var childToBottom = screen.height - (selfOffset!.dy + selfSize!.height);
      var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (childToBottom < 0) {
        _keyboardHeight = keyboardHeight;
        setState(() {});
        return;
      }
      if (childToBottom - keyboardHeight > -30) {
        return;
      }
      _keyboardHeight = keyboardHeight - childToBottom;
      setState(() {});
    });
  }
}
