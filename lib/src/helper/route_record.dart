import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

class RouteRecord {
  factory RouteRecord() => instance;
  static RouteRecord? _instance;

  static RouteRecord get instance => _instance ??= RouteRecord._internal();

  RouteRecord._internal() {
    routeQueue = DoubleLinkedQueue();
  }

  late Queue<Route<dynamic>> routeQueue;

  void push(Route<dynamic> route) {
    if (DialogProxy.instance.dialogQueue.isEmpty) return;

    routeQueue.add(route);
  }

  void pop(Route<dynamic> route) {
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
        if (routeQueue.isNotEmpty) {
          var route = routeQueue.last;
          if (info.useSystem && route.settings.name != SmartTag.systemDialog) {
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
}
