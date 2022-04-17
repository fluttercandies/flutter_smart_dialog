import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

class RouteRecord {
  factory RouteRecord() => instance;
  static RouteRecord? _instance;

  static RouteRecord get instance => _instance ??= RouteRecord._internal();

  late Queue<Route<dynamic>> routeQueue;
  static Route<dynamic>? curRoute;
  static Route<dynamic>? popRoute;

  RouteRecord._internal() {
    routeQueue = DoubleLinkedQueue();
  }

  void push(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _offstageDialog(previousRoute);
    if (DialogProxy.instance.dialogQueue.isEmpty) return;
    routeQueue.add(route);
  }

  void pop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onstageDialog(previousRoute);
    if (routeQueue.isEmpty) return;
    routeQueue.remove(route);
  }

  bool handleSmartDialog() {
    bool shouldHandle = true;
    try {
      if (DialogProxy.instance.dialogQueue.isEmpty) {
        if (routeQueue.isNotEmpty) routeQueue.clear();
        shouldHandle = false;
      } else {
        var route = routeQueue.last;
        var info = DialogProxy.instance.dialogQueue.last;

        if ((info.useSystem && route.settings.name != SmartTag.systemDialog) ||
            info.dialog.mainDialog.offstage ||
            info.permanent) {
          shouldHandle = false;
        }
      }
    } catch (e) {
      shouldHandle = false;
      print('SmartDialog back event error:${e.toString()}');
    }

    return shouldHandle;
  }

  void _offstageDialog(Route<dynamic>? curRoute) {
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = true;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }

  void _onstageDialog(Route<dynamic>? curRoute) {
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = false;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }
}
