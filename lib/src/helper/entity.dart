import 'package:flutter_smart_dialog/src/custom/custom_dialog.dart';

class DialogInfo {
  DialogInfo(this.dialog, this.backDismiss, this.isUseAnimation);

  final CustomDialog dialog;

  final bool backDismiss;

  final bool isUseAnimation;
}
