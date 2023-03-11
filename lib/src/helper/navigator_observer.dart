import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';

import '../data/dialog_info.dart';
import 'dialog_proxy.dart';

class SmartNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    DialogProxy.contextNavigator ??= navigator?.context;
    RouteRecord.curRoute = route;
    RouteRecord.instance.push(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    RouteRecord.curRoute = previousRoute;
    RouteRecord.instance.pop(route, previousRoute);

    if (!SmartDialog.config.isExist ||
        route.settings.name == SmartTag.systemDialog) {
      return;
    }

    if (SmartDialog.config.isExistLoading) {
      DialogProxy.instance.dismiss(
        status: SmartStatus.loading,
        closeType: CloseType.route,
      );
    }

    //smart close dialog
    var removeList = <DialogInfo>[];
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == route && item.bindPage && !(item.route is PopupRoute)) {
        removeList.add(item);
      }
    }
    for (var i = removeList.length; i > 0; i--) {
      DialogProxy.instance.dismiss(
        status: SmartStatus.dialog,
        closeType: CloseType.route,
        tag: removeList[i - 1].tag,
      );
    }
  }
}
