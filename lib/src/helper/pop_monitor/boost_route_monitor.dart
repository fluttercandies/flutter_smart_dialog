import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/kit/log.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

import 'monitor_pop_route.dart';

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

      await Future.delayed(const Duration(milliseconds: 1));
      if (route?.isActive == false) {
        _monitorRouteMount(route, ++count);
        return;
      }

      if (route is ModalRoute) {
        willPopCallback() async {
          if (MonitorPopRoute.handleSmartDialog()) {
            DialogProxy.instance.dismiss(
              status: SmartStatus.smart,
              closeType: CloseType.back,
            );
            return false;
          }
          return true;
        }

        // TODO: `addScopedWillPopCallback()` was deprecated after v3.12.0-1.0.pre.
        // ignore: deprecated_member_use
        route.addScopedWillPopCallback(willPopCallback);
        DialogProxy.contextNavigator = route.subtreeContext;
      }
    } catch (e) {
      SmartLog.d(e);
      _monitorRouteMount(route, ++count);
    }
  }
}
