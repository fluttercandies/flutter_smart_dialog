import 'base_dialog.dart';

class DialogInfo {
  DialogInfo({
    required this.dialog,
    required this.backDismiss,
    required this.isUseAnimation,
    required this.tag,
  });

  final BaseDialog dialog;

  final bool backDismiss;

  final bool isUseAnimation;

  final String? tag;
}
