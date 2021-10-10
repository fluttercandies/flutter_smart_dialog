import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ToastWidget extends StatefulWidget {
  ToastWidget({
    Key? key,
    required this.msg,
    this.alignment = Alignment.bottomCenter,
  }) : super(key: key);

  ///信息
  final String msg;

  ///toast显示位置
  final AlignmentGeometry alignment;

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> with WidgetsBindingObserver {
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
    return Align(
      alignment: widget.alignment,
      child: Container(
        margin: EdgeInsets.only(
          right: 30,
          left: 30,
          top: 50,
          bottom: (50 + _keyboardHeight),
        ),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('${widget.msg}', style: TextStyle(color: Colors.white)),
      ),
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
