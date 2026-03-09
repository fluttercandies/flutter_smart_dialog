import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/helper/route_record.dart';
import 'package:flutter_smart_dialog/src/kit/log.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

import '../data/dialog_info.dart';

class MonitorWidgetHelper {
  factory MonitorWidgetHelper() => instance;
  static MonitorWidgetHelper? _instance;

  static MonitorWidgetHelper get instance =>
      _instance ??= MonitorWidgetHelper._internal();

  late Queue<DialogInfo> monitorDialogQueue;

  bool prohibitMonitor = false;

  MonitorWidgetHelper._internal() {
    monitorDialogQueue = ListQueue();

    schedulerBinding.addPersistentFrameCallback((timeStamp) {
      if (monitorDialogQueue.isEmpty || prohibitMonitor) {
        return;
      }
      prohibitMonitor = true;
      var removeList = <DialogInfo>[];
      for (var item in monitorDialogQueue) {
        final context = item.bindWidget;
        if (!_isContextMounted(context)) {
          removeList.add(item);
          SmartLog.d(
            "The element(hashcode: ${item.bindWidget.hashCode}) is recycled and"
            " the 'bindWidget' dialog dismiss automatically",
          );
          continue;
        }

        _calculate(context!, item);
      }
      for (var i = removeList.length; i > 0; i--) {
        DialogProxy.instance.dismiss(
          status: SmartStatus.dialog,
          tag: removeList[i - 1].tag,
        );
      }
      prohibitMonitor = false;
    });
  }

  void _calculate(BuildContext context, DialogInfo item) {
    final curRoute = RouteRecord.curRoute;
    if (item.bindWidget != null &&
        curRoute != item.route &&
        curRoute is! PopupRoute) {
      item.dialog.hide();
      return;
    }

    var renderObject = _safeRenderBox(context);
    if (renderObject == null) {
      item.dialog.hide();
      return;
    }

    if (RouteRecord.curRoute == item.route) {
      // NonPage Scene
      _handleDialog(renderObject, item);
    } else {
      // Page Scene
      if (!item.bindPage) {
        _handleDialog(renderObject, item);
      }
    }
  }

  void _handleDialog(RenderBox renderObject, DialogInfo item) {
    try {
      var selfOffset = renderObject.localToGlobal(Offset.zero);
      if (selfOffset.dx < 0 ||
          selfOffset.dy < 0 ||
          selfOffset.dx.isNaN ||
          selfOffset.dy.isNaN ||
          selfOffset.dx.isInfinite ||
          selfOffset.dy.isInfinite) {
        item.dialog.hide();
      } else {
        item.dialog.appear();
      }
    } catch (_) {
      item.dialog.hide();
    }
  }

  bool _isContextMounted(BuildContext? context) {
    if (context == null) {
      return false;
    }
    if (context is Element) {
      return context.mounted;
    }
    return true;
  }

  RenderBox? _safeRenderBox(BuildContext context) {
    try {
      var renderObject = context.findRenderObject();
      if (renderObject is RenderBox &&
          renderObject.attached &&
          renderObject.hasSize) {
        return renderObject;
      }
    } catch (_) {}

    return null;
  }
}
