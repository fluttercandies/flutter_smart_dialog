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

    if (dialogTypes.isEmpty) return false;

    if (dialogTypes.contains(SmartAllDialogType.custom)) {
      if (SmartDialog.config.custom.isExist) return true;
    }
    if (dialogTypes.contains(SmartAllDialogType.attach)) {
      if (SmartDialog.config.attach.isExist) return true;
    }
    if (dialogTypes.contains(SmartAllDialogType.notify)) {
      if (SmartDialog.config.notify.isExist) return true;
    }
    if (dialogTypes.contains(SmartAllDialogType.loading)) {
      if (SmartDialog.config.loading.isExist) return true;
    }
    if (dialogTypes.contains(SmartAllDialogType.toast)) {
      if (SmartDialog.config.toast.isExist) return true;
    }

    return false;
  }
}