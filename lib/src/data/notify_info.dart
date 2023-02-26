import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';

import '../helper/dialog_proxy.dart';
import 'base_dialog.dart';

class NotifyInfo {
  NotifyInfo({
    required this.dialog,
    required this.tag,
  });

  final BaseDialog dialog;

  String? tag;

  Timer? displayTimer;
}
