import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../smart_dialog.dart';

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
    bool handleSystemPage = false;
    try {
      if (routeQueue.isEmpty || DialogProxy.instance.dialogQueue.isEmpty) {
        if (routeQueue.isNotEmpty) routeQueue.clear();
        handleSystemPage = false;
      } else {
        var route = routeQueue.last;
        var dialog = DialogProxy.instance.dialogQueue.last;

        if (dialog.useSystem && route.settings.name != SmartTag.systemDialog) {
          handleSystemPage = true;
        }
      }
    } catch (e) {
      print('SmartDialog back event error:${e.toString()}');
    }

    return SmartDialog.config.isExist && !handleSystemPage;
  }

  void _offstageDialog(Route<dynamic>? curRoute) {
    if (curRoute == null) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = true;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }

  void _onstageDialog(Route<dynamic>? curRoute) {
    if (curRoute == null) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = false;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }
}
