import 'package:flutter/material.dart';

import 'helper/dialog_proxy.dart';
import 'helper/monitor_pop_route.dart';

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
        //main layout
        OverlayEntry(builder: (BuildContext context) => child ?? Container()),

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

  static void monitor() => MonitorPopRoute.instance;
}
