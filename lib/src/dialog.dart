import 'package:flutter/material.dart';

import 'helper/dialog_proxy.dart';
import 'helper/monitor_pop_route.dart';

class FlutterSmartDialog extends StatefulWidget {
  final Widget? child;

  static void monitor() => MonitorPopRoute.instance;

  FlutterSmartDialog({Key? key, required this.child}) : super(key: key);

  @override
  _FlutterSmartDialogState createState() => _FlutterSmartDialogState();
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog> {
  @override
  void initState() {
    super.initState();
    
    // 解决Flutter Inspector -> select widget mode 功能失效问题
    DialogProxy.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Overlay(initialEntries: [
        //main layout
        OverlayEntry(
            builder: (BuildContext context) => widget.child ?? Container()),

        //provided separately for custom dialog
        OverlayEntry(builder: (BuildContext context) {
          DialogProxy.context = context;
          return Container();
        }),

        //provided separately for loading
        DialogProxy.instance.entryLoading,

        //provided separately for toast
        DialogProxy.instance.entryToast,
      ]),
    );
  }
}

///recommend the way of init
TransitionBuilder initFlutterSmartDialog({TransitionBuilder? builder}) {
  FlutterSmartDialog.monitor();

  return (BuildContext context, Widget? child) {
    return builder == null
        ? FlutterSmartDialog(child: child)
        : builder(context, FlutterSmartDialog(child: child));
  };
}
