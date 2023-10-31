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

    bool result = false;
    if (dialogTypes.contains(SmartAllDialogType.custom)) {
      result = SmartDialog.config.custom.isExist;
    }
    if (!result && dialogTypes.contains(SmartAllDialogType.attach)) {
      result = SmartDialog.config.attach.isExist;
    }
    if (!result && dialogTypes.contains(SmartAllDialogType.notify)) {
      result = SmartDialog.config.notify.isExist;
    }
    if (!result && dialogTypes.contains(SmartAllDialogType.loading)) {
      result = SmartDialog.config.loading.isExist;
    }
    if (!result && dialogTypes.contains(SmartAllDialogType.toast)) {
      result = SmartDialog.config.toast.isExist;
    }

    return false;
  }
}
