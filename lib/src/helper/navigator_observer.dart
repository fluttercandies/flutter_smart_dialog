import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'dialog_proxy.dart';

class SmartNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    if (!SmartDialog.config.isExist) return;

    var length = DialogProxy.instance.dialogList.length;
    for (var i = 0; i < length; i++) {
      var dialogs = DialogProxy.instance.dialogList;
      var item = dialogs[dialogs.length - 1];

      await DialogProxy.instance.dismiss(pop: true);
      if (item.isUseAnimation) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
  }
}
