import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

class DialogKit {
  static DialogKit? _instance;

  static DialogKit get instance => _instance ??= DialogKit._();

  DialogKit._();

  bool checkExist({
    String? tag,
    required Set<SmartAllDialogType> dialogTypes,
  }) {
    var dialogProxy = DialogProxy.instance;
    if (tag != null) {
      for (var element in dialogProxy.dialogQueue) {
        if (element.tag == tag) {
          return true;
        }
      }
      for (var element in dialogProxy.notifyQueue) {
        if (element.tag == tag) {
          return true;
        }
      }
      return false;
    }

    if (dialogTypes.contains(SmartAllDialogType.custom)) {
      return SmartDialog.config.custom.isExist;
    }
    if (dialogTypes.contains(SmartAllDialogType.attach)) {
      return SmartDialog.config.attach.isExist;
    }
    if (dialogTypes.contains(SmartAllDialogType.notify)) {
      return SmartDialog.config.notify.isExist;
    }
    if (dialogTypes.contains(SmartAllDialogType.loading)) {
      return SmartDialog.config.loading.isExist;
    }
    if (dialogTypes.contains(SmartAllDialogType.toast)) {
      return SmartDialog.config.toast.isExist;
    }

    return false;
  }
}
