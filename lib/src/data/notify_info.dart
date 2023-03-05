import 'dart:async';

import '../../flutter_smart_dialog.dart';
import 'base_dialog.dart';

class NotifyInfo {
  NotifyInfo({
    required this.dialog,
    required this.tag,
    required this.backType,
  });

  final BaseDialog dialog;

  String? tag;

  SmartBackType backType;

  Timer? displayTimer;
}
