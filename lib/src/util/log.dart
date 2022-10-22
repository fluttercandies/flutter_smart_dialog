import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class SmartLog {
  static d(Object? object) {
    if (kDebugMode) {
      developer.log("$object", name: 'SmartDialog');
    }
  }

  static i(Object? object) {
    developer.log("$object", name: 'SmartDialog');
  }
}
