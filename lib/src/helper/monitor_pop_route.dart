import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';

typedef PopTestFunc = bool Function();

class MonitorPopRoute with WidgetsBindingObserver {
  factory MonitorPopRoute() => instance;

  static MonitorPopRoute? _instance;

  static MonitorPopRoute get instance => _instance ??= MonitorPopRoute._();

  MonitorPopRoute._() {
    WidgetsFlutterBinding.ensureInitialized();
    //to prevent ensureInitialized changes, still use WidgetsBinding.instance
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    // handle contain system dialog and common condition
    if (RouteRecord.instance.handleSmartDialog()) {
      DialogProxy.instance.dismiss(status: SmartStatus.smart, back: true);
      return true;
    }

    return super.didPopRoute();
  }
}
