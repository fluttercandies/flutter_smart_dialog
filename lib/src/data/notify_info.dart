import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';

import '../../flutter_smart_dialog.dart';
import '../helper/dialog_proxy.dart';
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
