import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/util/log.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

class BoostRouteMonitor {
  static BoostRouteMonitor? _instance;

  static BoostRouteMonitor get instance => _instance ??= BoostRouteMonitor._();

  BoostRouteMonitor._();

  Route<dynamic>? push(Route<dynamic>? route) {
    ViewUtils.addSafeUse(() {
      _monitorRouteMount(route);
    });
    return route;
  }

  void _monitorRouteMount(Route<dynamic>? route) async {
    try {
      await Future.delayed(Duration(milliseconds: 1));
      if (route?.isActive == false) {
        _monitorRouteMount(route);
        return;
      }

      if (route is ModalRoute) {
        willPopCallback() async {
          if (SmartDialog.config.isExist) {
            SmartDialog.dismiss();
            return false;
          }
          return true;
        }

        route.addScopedWillPopCallback(willPopCallback);
        DialogProxy.contextNavigator = route.subtreeContext;
      }
    } catch (e) {
      SmartLog.d(e);
      _monitorRouteMount(route);
    }
  }
}
