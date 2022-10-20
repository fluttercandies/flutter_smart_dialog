import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

import '../data/dialog_info.dart';

class RouteRecord {
  factory RouteRecord() => instance;
  static RouteRecord? _instance;

  static RouteRecord get instance => _instance ??= RouteRecord._internal();

  late Queue<Route<dynamic>> routeQueue;
  static Route<dynamic>? curRoute;

  RouteRecord._internal() {
    routeQueue = DoubleLinkedQueue();
  }

  void push(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _hideDialog(previousRoute);
    if (DialogProxy.instance.dialogQueue.isEmpty) return;
    routeQueue.add(route);
  }

  void pop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _appearDialog(previousRoute);
    if (routeQueue.isEmpty) return;
    routeQueue.remove(route);
  }

  bool handleSmartDialog() {
    bool shouldHandle = true;
    try {
      //handle loading
      if (SmartDialog.config.isExistLoading) {
        return true;
      }

      //handle dialog
      if (DialogProxy.instance.dialogQueue.isEmpty) {
        if (routeQueue.isNotEmpty) routeQueue.clear();
        shouldHandle = false;
      } else {
        var info = DialogProxy.instance.dialogQueue.last;

        //deal with system dialog
        if (info.useSystem && routeQueue.isNotEmpty) {
          var route = routeQueue.last;
          if (route.settings.name != SmartTag.systemDialog) {
            shouldHandle = false;
          }
        } else {
          // deal with bindPage and permanent dialog
          if (!info.dialog.mainDialog.visible || info.permanent) {
            shouldHandle = false;
          }
        }
      }
    } catch (e) {
      shouldHandle = false;
      print('SmartDialog back event error:${e.toString()}');
    }

    return shouldHandle;
  }

  void _hideDialog(Route<dynamic>? curRoute) {
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (_needHandle(item, curRoute)) {
        item.dialog.hide();
      }
    }
  }

  void _appearDialog(Route<dynamic>? curRoute) {
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;
    for (var item in DialogProxy.instance.dialogQueue) {
      if (_needHandle(item, curRoute)) {
        item.dialog.appear();
      }
    }
  }

  bool _needHandle(DialogInfo item, Route<dynamic>? curRoute) {
    if (item.useSystem || item.permanent) {
      return false;
    }

    return item.route == curRoute && item.bindPage;
  }
}
