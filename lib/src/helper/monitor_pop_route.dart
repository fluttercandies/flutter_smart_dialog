import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/smart_dialog.dart';

typedef PopTestFunc = bool Function();

class MonitorPopRoute with WidgetsBindingObserver {
  static MonitorPopRoute? _instance;

  factory MonitorPopRoute() => instance;

  static MonitorPopRoute get instance => _instance ??= MonitorPopRoute._();

  MonitorPopRoute._() {
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    if (SmartDialog.config.isExist) {
      DialogProxy.instance.dismiss(back: true);
      return true;
    }

    return super.didPopRoute();
  }
}
