import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/util/log.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

class BoostRouteMonitor {
  static BoostRouteMonitor? _instance;

  static BoostRouteMonitor get instance => _instance ??= BoostRouteMonitor._();

  BoostRouteMonitor._();

  int threshold = 1000;

  Route<dynamic>? push(Route<dynamic>? route) {
    ViewUtils.addSafeUse(() {
      _monitorRouteMount(route, 0);
    });
    return route;
  }

  void _monitorRouteMount(Route<dynamic>? route, int count) async {
    try {
      if (count > threshold) {
        return;
      }

      await Future.delayed(Duration(milliseconds: 1));
      if (route?.isActive == false) {
        _monitorRouteMount(route, ++count);
        return;
      }

      if (route is ModalRoute) {
        willPopCallback() async {
          if (_handleSmartDialog()) {
            DialogProxy.instance.dismiss(status: SmartStatus.smart, closeType: CloseType.back);
            return false;
          }
          return true;
        }

        route.addScopedWillPopCallback(willPopCallback);
        DialogProxy.contextNavigator = route.subtreeContext;
      }
    } catch (e) {
      SmartLog.d(e);
      _monitorRouteMount(route, ++count);
    }
  }

  bool _handleSmartDialog() {
    bool shouldHandle = false;
    try {
      //handle loading
      if (SmartDialog.config.isExistLoading) {
        return true;
      }

      //handle dialog
      var dialogQueue = DialogProxy.instance.dialogQueue;

      if (dialogQueue.isEmpty) {
        return false;
      }

      for (var item in DialogProxy.instance.dialogQueue) {
        if (!item.permanent) {
          shouldHandle = true;
        }
      }
    } catch (e) {
      shouldHandle = false;
      print('SmartDialog back event error:${e.toString()}');
    }

    return shouldHandle;
  }
}
