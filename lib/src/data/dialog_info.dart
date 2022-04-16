import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';

import 'base_dialog.dart';

class DialogInfo {
  DialogInfo({
    required this.dialog,
    required this.backDismiss,
    required this.type,
    required this.tag,
    required this.useSystem,
    required this.bindPage,
    required this.route,
  });

  final BaseDialog dialog;

  final bool backDismiss;

  final DialogType type;

  final String? tag;

  final bool useSystem;

  final bool bindPage;

  final Route<dynamic>? route;
}
