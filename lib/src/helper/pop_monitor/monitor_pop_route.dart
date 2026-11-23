import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';
import 'package:material_ui/material_ui.dart';

import '../../../flutter_smart_dialog.dart';
import '../../data/dialog_info.dart';
import '../../data/smart_tag.dart';

class MonitorPopRoute with WidgetsBindingObserver {
  factory MonitorPopRoute() => instance;

  static MonitorPopRoute? _instance;

  static MonitorPopRoute get instance => _instance ??= MonitorPopRoute._();

  static final overlayBlocksBack = ValueNotifier(false);

  static bool get supportsPredictiveBack =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static void updateOverlayBackState() {
    if (!supportsPredictiveBack) return;
    final proxy = DialogProxy.instance;
    final dialog = proxy.dialogQueue.lastOrNull;
    overlayBlocksBack.value =
        (proxy.config.loading.isExist &&
            _blocksBack(proxy.loadingInfo.backType)) ||
        (proxy.config.notify.isExist &&
            proxy.notifyQueue.any((item) => _blocksBack(item.backType))) ||
        (dialog != null &&
            !dialog.useSystem &&
            _canHandleOverlayDialog(dialog) &&
            _blocksBack(dialog.backType));
  }

  static bool _blocksBack(SmartBackType? backType) =>
      backType == SmartBackType.normal || backType == SmartBackType.block;

  static bool _canHandleOverlayDialog(DialogInfo dialog) =>
      dialog.dialog.mainDialog.visible && !dialog.permanent;

  MonitorPopRoute._() {
    WidgetsFlutterBinding.ensureInitialized();
    //to prevent ensureInitialized changes, still use WidgetsBinding.instance
    widgetsBinding.addObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    return MonitorPopRoute.handBackEvent();
  }

  // 返回出true, 表示当前已处理, 需要拦截
  // 返回出false, 表示当前无需处理, 无需拦截
  static Future<bool> handBackEvent() async {
    //loading
    if (SmartDialog.config.loading.isExist) {
      final loadingInfo = DialogProxy.instance.loadingInfo;
      if (await loadingInfo.onBack?.call() == true) {
        return true;
      }
      if (loadingInfo.backType == SmartBackType.normal) {
        unawaited(
          DialogProxy.instance.dismiss<void>(
            status: SmartStatus.loading,
            closeType: CloseType.back,
          ),
        );
        return true;
      } else if (loadingInfo.backType == SmartBackType.block) {
        return true;
      }
    }

    //notify
    if (SmartDialog.config.notify.isExist) {
      var notifyQueue = DialogProxy.instance.notifyQueue;
      for (var i = notifyQueue.length - 1; i >= 0; i--) {
        var item = notifyQueue.elementAt(i);

        if (await item.onBack?.call() == true) {
          return true;
        }
        if (item.backType == SmartBackType.normal) {
          unawaited(
            DialogProxy.instance.dismiss<void>(
              status: SmartStatus.notify,
              closeType: CloseType.back,
              tag: item.tag,
            ),
          );
          return true;
        } else if (item.backType == SmartBackType.block) {
          return true;
        }
      }
    }

    // handle contain system dialog and common condition
    if (MonitorPopRoute.handleSmartDialog()) {
      var lastDialog = DialogProxy.instance.dialogQueue.last;
      if (await lastDialog.onBack?.call() == true) {
        return true;
      }
      if (lastDialog.backType == SmartBackType.normal) {
        unawaited(
          DialogProxy.instance.dismiss<void>(
            status: SmartStatus.dialog,
            closeType: CloseType.back,
          ),
        );
        return true;
      } else if (lastDialog.backType == SmartBackType.block) {
        return true;
      }
    }

    return false;
  }

  static bool handleSmartDialog() {
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
          if (!_canHandleOverlayDialog(info)) {
            shouldHandle = false;
          }
        }
      }
    } catch (e) {
      shouldHandle = false;
      debugPrint('SmartDialog back event error:${e.toString()}');
    }

    return shouldHandle;
  }
}
