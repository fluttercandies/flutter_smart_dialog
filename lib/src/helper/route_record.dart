import 'dart:collection';

import 'package:flutter/material.dart';
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
    _hideDialog(previousRoute, route);
    if (DialogProxy.instance.dialogQueue.isEmpty) return;
    routeQueue.add(route);
  }

  void replace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (DialogProxy.instance.dialogQueue.isEmpty) return;
    routeQueue.remove(oldRoute);
    if (newRoute != null) {
      routeQueue.add(newRoute);
    }
  }

  void pop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _appearDialog(route, previousRoute);
    if (routeQueue.isEmpty) return;
    routeQueue.remove(route);
  }

  void remove(Route<dynamic> route) {
    if (routeQueue.isEmpty) return;
    routeQueue.remove(route);
  }

  /// curRoute: 当前可见的路由 nextRoute: 下一路由
  void _hideDialog(Route<dynamic>? curRoute, Route<dynamic> nextRoute) {
    if (_banContinue(nextRoute)) return;

    for (var item in DialogProxy.instance.dialogQueue) {
      if (_needHandle(item, curRoute)) {
        item.dialog.hide();
      }
    }
  }

  /// curRoute: 当前可见的路由  preRoute: 前一路由
  void _appearDialog(Route<dynamic> curRoute, Route<dynamic>? preRoute) {
    if (_banContinue(curRoute)) return;

    for (var item in DialogProxy.instance.dialogQueue) {
      if (_needHandle(item, preRoute)) {
        item.dialog.appear();
      }
    }
  }

  bool _banContinue(Route<dynamic>? route) {
    return route == null ||
        DialogProxy.instance.dialogQueue.isEmpty ||
        (route is PopupRoute);
  }

  bool _needHandle(DialogInfo item, Route<dynamic>? route) {
    if (item.useSystem || item.permanent || (item.route is PopupRoute)) {
      return false;
    }

    return item.route == route && item.bindPage;
  }
}
