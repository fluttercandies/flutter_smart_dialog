import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class ViewUtils {
  static bool routeSafeUse = false;

  static void addSafeUse(VoidCallback callback) {
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      ViewUtils.addPostFrameCallback((timeStamp) => callback());
    } else {
      callback();
    }
  }

  static void addPostFrameCallback(FrameCallback callback) {
    widgetsBinding.addPostFrameCallback(callback);
  }
}

WidgetsBinding get widgetsBinding => WidgetsBinding.instance!;

SchedulerBinding get schedulerBinding => SchedulerBinding.instance!;
