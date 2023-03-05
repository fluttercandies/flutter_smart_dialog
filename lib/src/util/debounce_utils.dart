import '../../flutter_smart_dialog.dart';

enum DebounceType {
  custom,
  attach,
  notify,
  toast,
  mask,
}

class DebounceUtils {
  static DebounceUtils? _instance;

  static DebounceUtils get instance => _instance ??= DebounceUtils._();

  DebounceUtils._();

  Map<DebounceType, DateTime> map = {};

  bool banContinue(DebounceType type, bool debounce) {
    if (!debounce) {
      return false;
    }

    var limitTime = Duration.zero;
    if (type == DebounceType.custom) {
      limitTime = SmartDialog.config.custom.debounceTime;
    } else if (type == DebounceType.attach) {
      limitTime = SmartDialog.config.attach.debounceTime;
    } else if (type == DebounceType.notify) {
      limitTime = SmartDialog.config.notify.debounceTime;
    } else if (type == DebounceType.toast) {
      limitTime = SmartDialog.config.toast.debounceTime;
    } else if (type == DebounceType.mask) {
      limitTime = const Duration(milliseconds: 500);
    }

    var curTime = DateTime.now();
    DateTime? lastTime = map[type];
    map[type] = curTime;
    var banContinue = false;
    if (lastTime != null) {
      banContinue = curTime.difference(lastTime) < limitTime;
    }

    return banContinue;
  }
}
