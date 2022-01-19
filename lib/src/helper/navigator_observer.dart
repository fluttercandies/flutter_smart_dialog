import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/smart_dialog.dart';

import 'dialog_proxy.dart';

class SmartNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (DialogProxy.instance.dialogList.isNotEmpty) {}
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    print('${DialogProxy.pages?.length}');
    if (!SmartDialog.config.isExist) return;

    DialogProxy.instance.dismiss(status: SmartStatus.allDialog);
  }
}
