import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import 'helper/dialog_proxy.dart';
import 'helper/pop_monitor/boost_route_monitor.dart';
import 'helper/pop_monitor/monitor_pop_route.dart';
import 'widget/loading_widget.dart';

typedef FlutterSmartToastBuilder = Widget Function(String msg);
typedef FlutterSmartLoadingBuilder = Widget Function(String msg);
typedef FlutterSmartStyleBuilder = Widget Function(Widget child);

class FlutterSmartDialog extends StatefulWidget {
  FlutterSmartDialog({
    Key? key,
    required this.child,
    this.toastBuilder,
    this.loadingBuilder,
    this.styleBuilder,
    this.initType,
  }) : super(key: key);

  final Widget? child;

  ///set default toast widget
  final FlutterSmartToastBuilder? toastBuilder;

  ///set default loading widget
  final FlutterSmartLoadingBuilder? loadingBuilder;

  ///Compatible with cupertino style
  final FlutterSmartStyleBuilder? styleBuilder;

  ///inti type
  final Set<SmartInitType>? initType;

  @override
  _FlutterSmartDialogState createState() => _FlutterSmartDialogState();

  static final observer = SmartNavigatorObserver();

  ///Compatible with flutter_boost
  static Route<dynamic>? boostMonitor(Route<dynamic>? route) =>
      BoostRouteMonitor.instance.push(route);

  ///recommend the way of init
  static TransitionBuilder init({
    TransitionBuilder? builder,
    //set default toast widget
    FlutterSmartToastBuilder? toastBuilder,
    //set default loading widget
    FlutterSmartLoadingBuilder? loadingBuilder,
    //Compatible with cupertino style
    FlutterSmartStyleBuilder? styleBuilder,
    //init type
    Set<SmartInitType>? initType,
  }) {
    MonitorPopRoute.instance;

    return (BuildContext context, Widget? child) {
      return builder == null
          ? FlutterSmartDialog(
              toastBuilder: toastBuilder,
              loadingBuilder: loadingBuilder,
              styleBuilder: styleBuilder,
              initType: initType,
              child: child,
            )
          : builder(
              context,
              FlutterSmartDialog(
                toastBuilder: toastBuilder,
                loadingBuilder: loadingBuilder,
                styleBuilder: styleBuilder,
                initType: initType,
                child: child,
              ),
            );
    };
  }
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog> {
  late FlutterSmartStyleBuilder styleBuilder;
  late Set<SmartInitType> initType;

  @override
  void initState() {
    ViewUtils.addSafeUse(() {
      try {
        var navigator = widget.child as Navigator;
        var key = navigator.key as GlobalKey;
        DialogProxy.contextNavigator = key.currentContext;
      } catch (e) {}
    });

    // init param
    styleBuilder = widget.styleBuilder ??
        (Widget child) {
          return Material(color: Colors.transparent, child: child);
        };
    initType = widget.initType ??
        {SmartInitType.custom, SmartInitType.attach, SmartInitType.loading, SmartInitType.toast};

    // default toast / loading
    if (initType.contains(SmartInitType.toast)){
      DialogProxy.instance.toastBuilder =
          widget.toastBuilder ?? (String msg) => ToastWidget(msg: msg);
    }
    if (initType.contains(SmartInitType.loading)){
      DialogProxy.instance.loadingBuilder =
          widget.loadingBuilder ?? (String msg) => LoadingWidget(msg: msg);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return styleBuilder(Overlay(initialEntries: [
      //main layout
      OverlayEntry(
        builder: (BuildContext context) => widget.child ?? Container(),
      ),

      //provided separately for custom dialog
      if (initType.contains(SmartInitType.custom))
        OverlayEntry(builder: (BuildContext context) {
          DialogProxy.contextCustom = context;
          return Container();
        }),

      //provided separately for attach dialog
      if (initType.contains(SmartInitType.attach))
        OverlayEntry(builder: (BuildContext context) {
          DialogProxy.contextAttach = context;
          return Container();
        }),

      //provided separately for loading
      if (initType.contains(SmartInitType.loading)) DialogProxy.instance.entryLoading,

      //provided separately for toast
      if (initType.contains(SmartInitType.toast)) DialogProxy.instance.entryToast,
    ]));
  }
}
