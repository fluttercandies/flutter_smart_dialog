import 'package:flutter/material.dart';
import '../flutter_smart_dialog.dart';
import 'config/smart_config_attributes.dart';
import 'helper/navigator_observer.dart';
import 'kit/view_utils.dart';
import 'widget/default/notify_alert.dart';
import 'helper/dialog_proxy.dart';
import 'helper/pop_monitor/boost_route_monitor.dart';
import 'helper/pop_monitor/monitor_pop_route.dart';
import 'widget/default/loading_widget.dart';
import 'widget/default/toast_widget.dart';

/// A typedef for a function that builds a customizable toast widget.
typedef FlutterSmartToastBuilder = Widget Function({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
  Widget? trailingWidget,
  Color? color,
  Color? txtColor,
  TextStyle? txtStyle,
  EdgeInsets? margin,
  double? spaceAroundTxt,
  EdgeInsets? padding,
  bool isHorizontal,
  TextStyle? titleStyle,
  BorderRadius? borderRadius,
});

/// A typedef for a function that builds a customizable loading widget.
typedef FlutterSmartLoadingBuilder = Widget Function({
  String? msg,
  Color? color,
  Color? txtColor,
  Color? loadingColor,
  double spacer,
  Widget? loadingIndicator,
  BorderRadius? borderRadius,
  TextStyle? msgStyle,
  bool isHorizontal,
});

typedef FlutterSmartStyleBuilder = Widget Function(Widget child);

class FlutterSmartDialog extends StatefulWidget {
  const FlutterSmartDialog({
    Key? key,
    required this.child,
    this.toastBuilder,
    this.loadingBuilder,
    this.notifyStyle,
    this.styleBuilder,
    this.initType,
    this.defaultAttributes,
  }) : super(key: key);

  final Widget? child;

  ///set default toast widget
  final FlutterSmartToastBuilder? toastBuilder;

  ///set default loading widget
  final FlutterSmartLoadingBuilder? loadingBuilder;

  ///set default notify style
  final FlutterSmartNotifyStyle? notifyStyle;

  ///Compatible with cupertino style
  final FlutterSmartStyleBuilder? styleBuilder;

  ///inti type
  final Set<SmartInitType>? initType;

  ///set default attributes
  final SmartConfigAttributes? defaultAttributes;

  @override
  State<FlutterSmartDialog> createState() => _FlutterSmartDialogState();

  static SmartNavigatorObserver get observer => SmartNavigatorObserver();

  ///Compatible with flutter_boost
  static Route<dynamic>? boostMonitor(Route<dynamic>? route) => BoostRouteMonitor.instance.push(route);

  ///recommend the way of init
  static TransitionBuilder init({
    TransitionBuilder? builder,
    //set default toast widget
    FlutterSmartToastBuilder? toastBuilder,
    //set default loading widget
    FlutterSmartLoadingBuilder? loadingBuilder,
    //set default notify style
    FlutterSmartNotifyStyle? notifyStyle,
    //Compatible with cupertino style
    FlutterSmartStyleBuilder? styleBuilder,
    //init type
    Set<SmartInitType>? initType,
    //set default attributes
    SmartConfigAttributes? defaultAttributes,
  }) {
    MonitorPopRoute.instance;

    return (BuildContext context, Widget? child) {
      return builder == null
          ? FlutterSmartDialog(
              toastBuilder: toastBuilder,
              loadingBuilder: loadingBuilder,
              notifyStyle: notifyStyle,
              styleBuilder: styleBuilder,
              initType: initType,
              defaultAttributes: defaultAttributes,
              child: child,
            )
          : builder(
              context,
              FlutterSmartDialog(
                toastBuilder: toastBuilder,
                loadingBuilder: loadingBuilder,
                notifyStyle: notifyStyle,
                styleBuilder: styleBuilder,
                initType: initType,
                defaultAttributes: defaultAttributes,
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
        BuildContext? context;
        if (widget.child is Navigator) {
          context = getNavigatorContext(widget.child as Navigator);
        } else if (widget.child is FocusScope) {
          var focusScope = widget.child as FocusScope;
          if (focusScope.child is Navigator) {
            context = getNavigatorContext(focusScope.child as Navigator);
          }
        }
        DialogProxy.contextNavigator = context;
      } catch (_) {}
    });

    // init param
    styleBuilder = widget.styleBuilder ?? (Widget child) => Material(color: Colors.transparent, child: child);
    initType = widget.initType ??
        {
          SmartInitType.custom,
          SmartInitType.attach,
          SmartInitType.loading,
          SmartInitType.toast,
          SmartInitType.notify,
        };

    if (widget.defaultAttributes != null) {
      DialogProxy.instance.config.configureDefaultAttributes(widget.defaultAttributes!);
    }

    // solve Flutter Inspector -> select widget mode function failure problem
    DialogProxy.instance.initialize(initType);

    // default toast / loading / notify
    if (initType.contains(SmartInitType.toast)) {
      DialogProxy.instance.toastBuilder = widget.toastBuilder ??
          (((
                  {required String msg,
                  String? title,
                  Widget? titleWidget,
                  Widget? leadingWidget,
                  Widget? trailingWidget,
                  Color? color,
                  Color? txtColor,
                  TextStyle? txtStyle,
                  EdgeInsets? margin,
                  double? spaceAroundTxt,
                  EdgeInsets? padding,
                  bool isHorizontal = true,
                  TextStyle? titleStyle,
                  BorderRadius? borderRadius}) =>
              ToastWidget(
                msg: msg,
                title: title,
                titleWidget: titleWidget,
                leadingWidget: leadingWidget,
                trailingWidget: trailingWidget,
                color: color,
                txtColor: txtColor,
                txtStyle: txtStyle,
                margin: margin,
                spaceAroundTxt: spaceAroundTxt,
                padding: padding,
                isHorizontal: isHorizontal,
                titleStyle: titleStyle,
                borderRadius: borderRadius,
              )));
    }

    if (initType.contains(SmartInitType.loading)) {
      DialogProxy.instance.loadingBuilder = widget.loadingBuilder ??
          (
                  {String? msg,
                  Color? color,
                  Color? txtColor,
                  Color? loadingColor,
                  double spacer = 20,
                  Widget? loadingIndicator,
                  BorderRadius? borderRadius,
                  TextStyle? msgStyle,
                  bool isHorizontal = false}) =>
              LoadingWidget(
                msg: msg,
                color: color,
                txtColor: txtColor,
                loadingColor: loadingColor,
                spacer: spacer,
                loadingIndicator: loadingIndicator,
                borderRadius: borderRadius,
                msgStyle: msgStyle,
                isHorizontal: isHorizontal,
              );
    }

    if (initType.contains(SmartInitType.notify)) {
      var notify = widget.notifyStyle;
      DialogProxy.instance.notifyStyle = FlutterSmartNotifyStyle(
        successBuilder: notify?.successBuilder ?? defaultSuccessBuilder,
        failureBuilder: notify?.failureBuilder ?? defaultFailureBuilder,
        warningBuilder: notify?.warningBuilder ?? defaultWarningBuilder,
        alertBuilder: notify?.alertBuilder ?? defaultAlertBuilder,
        errorBuilder: notify?.errorBuilder ?? defaultErrorBuilder,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return styleBuilder(
      Overlay(initialEntries: [
        //main layout
        OverlayEntry(
          builder: (BuildContext context) {
            if (initType.contains(SmartInitType.custom)) {
              DialogProxy.contextCustom = context;
            }

            if (initType.contains(SmartInitType.attach)) {
              DialogProxy.contextAttach = context;
            }

            if (initType.contains(SmartInitType.notify)) {
              DialogProxy.contextNotify = context;
            }

            if (initType.contains(SmartInitType.toast)) {
              DialogProxy.contextToast = context;
            }

            return widget.child ?? Container();
          },
        ),

        // if (initType.contains(SmartInitType.notify))
        //   DialogProxy.instance.entryNotify,

        //provided separately for loading
        if (initType.contains(SmartInitType.loading)) DialogProxy.instance.entryLoading,
      ]),
    );
  }

  BuildContext? getNavigatorContext(Navigator navigator) {
    BuildContext? context;
    if (navigator.key is GlobalKey) {
      context = (navigator.key as GlobalKey).currentContext;
    }
    return context;
  }
}