import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class ViewUtils {
  static void addSafeUse(VoidCallback callback) {
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      widgetsBinding.addPostFrameCallback((timeStamp) => callback());
    } else {
      callback();
    }
  }
}

WidgetsBinding get widgetsBinding => WidgetsBinding.instance;

SchedulerBinding get schedulerBinding => SchedulerBinding.instance;

OverlayState overlay(BuildContext context) => Overlay.of(context)!;
