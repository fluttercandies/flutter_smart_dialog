import 'package:flutter/material.dart';

import 'smart_dialog.dart';

class FlutterSmartDialog extends StatelessWidget {
  FlutterSmartDialog({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Overlay(initialEntries: [
        //主体布局
        OverlayEntry(builder: (BuildContext context) => child ?? Container()),

        //添加的控件,覆盖在主体布局上面
        SmartDialog.instance.entryMain,

        //单独提供给Loading
        SmartDialog.instance.entryLoading,

        //单独提供给Toast
        SmartDialog.instance.entryToast,
      ]),
    );
  }
}
