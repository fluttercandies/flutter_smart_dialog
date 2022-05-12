import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class ViewUtils {
  static bool routeSafeUse = false;

  static void addRouteSafeUse(VoidCallback callback) async {
    if (routeSafeUse) {
      callback();
      return;
    }

    ViewUtils.addPostFrameCallback((timeStamp) {
      routeSafeUse = true;
      callback();
    });
  }

  static void addPostFrameCallback(FrameCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback(callback);
  }
}
