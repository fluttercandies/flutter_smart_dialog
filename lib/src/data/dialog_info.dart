import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/typedef.dart';

import '../../flutter_smart_dialog.dart';
import '../helper/dialog_proxy.dart';
import 'base_dialog.dart';

class DialogInfo {
  DialogInfo({
    required this.dialog,
    required this.type,
    required this.tag,
    required this.permanent,
    required this.useSystem,
    required this.bindPage,
    required this.route,
    required this.bindWidget,
    required this.backType,
    required this.onBack,
  });

  final BaseDialog dialog;

  final DialogType type;

  String? tag;

  final bool permanent;

  final bool useSystem;

  final bool bindPage;

  final Route<dynamic>? route;

  final BuildContext? bindWidget;

  Timer? displayTimer;

  final SmartBackType? backType;

  final SmartOnBack? onBack;
}
