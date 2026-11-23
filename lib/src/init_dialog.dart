import 'dart:async';

import 'package:flutter/services.dart' show PredictiveBackEvent;
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/default/notify_alter.dart';
import 'package:flutter_smart_dialog/src/widget/default/notify_error.dart';
import 'package:flutter_smart_dialog/src/widget/default/notify_failure.dart';
import 'package:material_ui/material_ui.dart';

import 'config/enum_config.dart';
import 'data/notify_style.dart';
import 'helper/dialog_proxy.dart';
import 'helper/pop_monitor/boost_route_monitor.dart';
import 'helper/pop_monitor/monitor_pop_route.dart';
import 'helper/route_record.dart';
import 'widget/default/loading_widget.dart';
import 'widget/default/notify_success.dart';
import 'widget/default/notify_warning.dart';
import 'widget/default/toast_widget.dart';

typedef FlutterSmartToastBuilder = Widget Function(String msg);
typedef FlutterSmartLoadingBuilder = Widget Function(String msg);
typedef FlutterSmartStyleBuilder = Widget Function(Widget child);

class FlutterSmartDialog extends StatefulWidget {
  const FlutterSmartDialog({
    super.key,
    required this.child,
    this.toastBuilder,
    this.loadingBuilder,
    this.notifyStyle,
    this.styleBuilder,
    this.initType,
  });

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

  @override
  State<FlutterSmartDialog> createState() => _FlutterSmartDialogState();

  static SmartNavigatorObserver get observer => SmartNavigatorObserver();

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
    //set default notify style
    FlutterSmartNotifyStyle? notifyStyle,
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
              notifyStyle: notifyStyle,
              styleBuilder: styleBuilder,
              initType: initType,
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
                child: child,
              ),
            );
    };
  }
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog>
    with WidgetsBindingObserver {
  late FlutterSmartStyleBuilder styleBuilder;
  late Set<SmartInitType> initType;
  late final bool _supportsPredictiveBack =
      MonitorPopRoute.supportsPredictiveBack;
  bool _navigatorHandlesBack = false;

  Widget? get _routingWidget {
    final child = widget.child;
    return child is FocusScope ? child.child : child;
  }

  @override
  void initState() {
    if (_supportsPredictiveBack) {
      widgetsBinding.addObserver(this);
      MonitorPopRoute.overlayBlocksBack.addListener(_updateBackNotification);
    }

    ViewUtils.addSafeUse(() {
      final routing = _routingWidget;
      DialogProxy.contextNavigator = routing is Navigator
          ? getNavigatorContext(routing)
          : null;
    });

    // init param
    styleBuilder =
        widget.styleBuilder ??
        (Widget child) => Material(color: Colors.transparent, child: child);
    initType =
        widget.initType ??
        {
          SmartInitType.custom,
          SmartInitType.attach,
          SmartInitType.loading,
          SmartInitType.toast,
          SmartInitType.notify,
        };

    // solve Flutter Inspector -> select widget mode function failure problem
    DialogProxy.instance.initialize(initType);

    // default toast / loading / notify
    if (initType.contains(SmartInitType.toast)) {
      DialogProxy.instance.toastBuilder =
          widget.toastBuilder ?? (String msg) => ToastWidget(msg: msg);
    }
    if (initType.contains(SmartInitType.loading)) {
      DialogProxy.instance.loadingBuilder =
          widget.loadingBuilder ?? (String msg) => LoadingWidget(msg: msg);
    }
    if (initType.contains(SmartInitType.notify)) {
      var notify = widget.notifyStyle;
      DialogProxy.instance.notifyStyle = FlutterSmartNotifyStyle(
        successBuilder:
            notify?.successBuilder ?? (msg) => NotifySuccess(msg: msg),
        failureBuilder:
            notify?.failureBuilder ?? (msg) => NotifyFailure(msg: msg),
        warningBuilder:
            notify?.warningBuilder ?? (msg) => NotifyWarning(msg: msg),
        alertBuilder: notify?.alertBuilder ?? (msg) => NotifyAlter(msg: msg),
        errorBuilder: notify?.errorBuilder ?? (msg) => NotifyError(msg: msg),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = Overlay(
      initialEntries: [
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
        if (initType.contains(SmartInitType.loading))
          DialogProxy.instance.entryLoading,
      ],
    );
    final content = styleBuilder(overlay);
    return _supportsPredictiveBack
        ? NotificationListener<NavigationNotification>(
            onNotification: _handleNavigationNotification,
            child: content,
          )
        : content;
  }

  bool _handleNavigationNotification(NavigationNotification notification) {
    _navigatorHandlesBack = notification.canHandlePop;
    if (!_navigatorHandlesBack && MonitorPopRoute.overlayBlocksBack.value) {
      const NavigationNotification(canHandlePop: true).dispatch(context);
      return true;
    }
    return false;
  }

  void _updateBackNotification() {
    ViewUtils.addSafeUse(() {
      if (mounted && !_navigatorHandlesBack) {
        NavigationNotification(
          canHandlePop: MonitorPopRoute.overlayBlocksBack.value,
        ).dispatch(context);
      }
    });
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!MonitorPopRoute.overlayBlocksBack.value) return false;
    if (backEvent.isButtonEvent) return true;

    final navigator = _backNavigator;
    if (navigator == null) return !_navigatorHandlesBack;
    // A true predicate inspects the top route without popping it.
    navigator.popUntil((route) {
      if (route is ModalRoute<dynamic> && route.popGestureEnabled) {
        final entry = _OverlayBackGestureEntry();
        route.registerPopEntry(entry);
        // Flutter's route observers check popGestureEnabled in the same
        // dispatch. Release the entry before any subsequent maybePop call.
        scheduleMicrotask(() {
          route.unregisterPopEntry(entry);
          entry.canPopNotifier.dispose();
        });
      }
      return true;
    });
    return true;
  }

  @override
  void handleCommitBackGesture() {
    if (mounted) unawaited(MonitorPopRoute.handBackEvent());
  }

  NavigatorState? get _backNavigator {
    final routing = _routingWidget;
    if (routing is Navigator) {
      final key = routing.key;
      final state = key is GlobalKey ? key.currentState : null;
      return state is NavigatorState ? state : null;
    }
    if (routing case Router<Object>(
      routerDelegate: final PopNavigatorRouterDelegateMixin<Object> delegate,
    )) {
      final state = delegate.navigatorKey?.currentState;
      if (state != null) return state;
    }
    final observedNavigator = RouteRecord.curRoute?.navigator;
    if (observedNavigator != null) return observedNavigator;
    final navigatorContext = DialogProxy.contextNavigator;
    if (navigatorContext == null || !navigatorContext.mounted) return null;
    return Navigator.maybeOf(navigatorContext);
  }

  @override
  void dispose() {
    if (_supportsPredictiveBack) {
      MonitorPopRoute.overlayBlocksBack.removeListener(_updateBackNotification);
      widgetsBinding.removeObserver(this);
    }
    super.dispose();
  }

  BuildContext? getNavigatorContext(Navigator navigator) {
    BuildContext? context;
    if (navigator.key is GlobalKey) {
      context = (navigator.key as GlobalKey).currentContext;
    }
    return context;
  }
}

class _OverlayBackGestureEntry extends PopEntry<Object?> {
  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier(false);
}
