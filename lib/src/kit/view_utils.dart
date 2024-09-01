import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../helper/dialog_proxy.dart';

class ViewUtils {
  static void addSafeUse(VoidCallback callback) {
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      widgetsBinding.addPostFrameCallback((timeStamp) => callback());
    } else {
      callback();
    }
  }

  static Future<void> awaitSafeUse({VoidCallback? onPostFrame}) async {
    final completer = Completer();
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      widgetsBinding.addPostFrameCallback((timeStamp) {
        onPostFrame?.call();
        if (!completer.isCompleted) completer.complete();
      });
    } else {
      onPostFrame?.call();
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  static Future<void> awaitPostFrame({VoidCallback? onPostFrame}) async {
    final completer = Completer();
    widgetsBinding.addPostFrameCallback((timeStamp) {
      onPostFrame?.call();
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  static bool isDarkModel() {
    if (DialogProxy.contextNavigator == null) {
      return false;
    }

    var brightness = Theme.of(DialogProxy.contextNavigator!).brightness;
    return brightness == Brightness.dark;
  }
}

class ThemeStyle {
  static Color get backgroundColor {
    return ViewUtils.isDarkModel() ? const Color(0xFF606060) : Colors.black;
  }

  static Color get textColor {
    return ViewUtils.isDarkModel() ? Colors.white : Colors.white;
  }
}

WidgetsBinding get widgetsBinding => WidgetsBinding.instance;

SchedulerBinding get schedulerBinding => SchedulerBinding.instance;

OverlayState overlay(BuildContext context) => Overlay.of(context);
