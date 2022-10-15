import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class SmartLog {
  static d(String msg) {
    if (kDebugMode) {
      developer.log(msg, name: 'SmartDialog');
    }
  }

  static i(String msg) {
    developer.log(msg, name: 'SmartDialog');
  }
}
