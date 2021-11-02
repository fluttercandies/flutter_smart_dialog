import 'package:flutter_smart_dialog/src/strategy/action.dart';

class DialogInfo {
  DialogInfo(this.action, this.backDismiss, this.isUseAnimation);

  final DialogAction action;

  final bool backDismiss;

  final bool isUseAnimation;
}
