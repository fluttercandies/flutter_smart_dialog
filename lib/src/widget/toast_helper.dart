import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ToastHelper extends StatefulWidget {
  ToastHelper({
    Key? key,
    required this.child,
  }) : super(key: key);

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
    WidgetsBinding.instance?.addObserver(this);
    _dealKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _keyboardHeight),
      child: widget.child,
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _dealKeyboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void _dealKeyboard() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      setState(() {});
    });
  }
}
