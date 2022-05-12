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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dealKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _keyboardHeight),
      child: widget.consumeEvent
          ? widget.child
          : IgnorePointer(child: widget.child),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _dealKeyboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _dealKeyboard() {
    ViewUtils.addPostFrameCallback((_) {
      if (!mounted) return;
      _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      setState(() {});
    });
  }
}
