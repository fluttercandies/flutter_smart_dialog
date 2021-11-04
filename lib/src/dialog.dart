import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';

import 'helper/dialog_proxy.dart';
import 'helper/monitor_pop_route.dart';

class FlutterSmartDialog extends StatefulWidget {
  FlutterSmartDialog({Key? key, required this.child}) : super(key: key);

  final Widget? child;

  @override
  _FlutterSmartDialogState createState() => _FlutterSmartDialogState();

  static final observer = SmartNavigatorObserver();

  static void monitor() => MonitorPopRoute.instance;

  ///recommend the way of init
  static TransitionBuilder init({TransitionBuilder? builder}) {
    monitor();

    return (BuildContext context, Widget? child) {
      return builder == null
          ? FlutterSmartDialog(child: child)
          : builder(context, FlutterSmartDialog(child: child));
    };
  }
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog> {
  @override
  void initState() {
    // solve Flutter Inspector -> select widget mode function failure problem
    DialogProxy.instance.initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Overlay(initialEntries: [
        //main layout
        OverlayEntry(
          builder: (BuildContext context) => widget.child ?? Container(),
        ),

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
