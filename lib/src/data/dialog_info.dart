import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';

import 'base_dialog.dart';

class DialogInfo {
  DialogInfo({
    required this.dialog,
    required this.backDismiss,
    required this.isUseAnimation,
    required this.type,
    required this.tag,
    required this.useSystem,
  });

  final BaseDialog dialog;

  final bool backDismiss;

  final bool isUseAnimation;

  final DialogType type;

  final String? tag;

  final bool useSystem;
}
