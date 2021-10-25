import 'package:flutter_smart_dialog/src/strategy/action.dart';

class DialogInfo {
  DialogInfo(this.action, this.backDismiss);

  final DialogAction action;

  final bool backDismiss;
}
