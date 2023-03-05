import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

import '../../../flutter_smart_dialog.dart';
import '../../data/smart_tag.dart';

class MonitorPopRoute with WidgetsBindingObserver {
  factory MonitorPopRoute() => instance;

  static MonitorPopRoute? _instance;

  static MonitorPopRoute get instance => _instance ??= MonitorPopRoute._();

  MonitorPopRoute._() {
    WidgetsFlutterBinding.ensureInitialized();
    //to prevent ensureInitialized changes, still use WidgetsBinding.instance
    widgetsBinding.addObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    //loading
    if (SmartDialog.config.isExistLoading) {
      DialogProxy.instance.dismiss(
        status: SmartStatus.loading,
        closeType: CloseType.back,
      );
      return true;
    }

    //notify
    if (SmartDialog.config.notify.isExist) {
      var notifyQueue = DialogProxy.instance.notifyQueue;
      for (var i = notifyQueue.length - 1; i >= 0; i--) {
        var item = notifyQueue.elementAt(i);
        if (item.backType == SmartBackType.normal) {
          DialogProxy.instance.dismiss(
            status: SmartStatus.notify,
            closeType: CloseType.back,
            tag: item.tag,
          );
          return true;
        } else if (item.backType == SmartBackType.block) {
          return true;
        }
      }
    }

    // handle contain system dialog and common condition
    if (handleSmartDialog()) {
      DialogProxy.instance.dismiss(
        status: SmartStatus.dialog,
        closeType: CloseType.back,
      );
      return true;
    }

    return super.didPopRoute();
  }

  bool handleSmartDialog() {
    bool shouldHandle = true;
    var routeQueue = RouteRecord.instance.routeQueue;
    try {
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
}
