import '../config/enum_config.dart';
import '../helper/dialog_proxy.dart';

/// widget controller
abstract class BaseController {
  Future<void> dismiss({CloseType closeType = CloseType.normal});

  bool judgeOpenDialogType(SmartNonAnimationType nonAnimationType) {
    if (nonAnimationType == SmartNonAnimationType.openDialog_nonAnimation) {
      return true;
    }

    return false;
  }

  bool judgeDismissDialogType(
    CloseType closeType,
    SmartNonAnimationType nonAnimationType,
  ) {
    if (nonAnimationType == SmartNonAnimationType.closeDialog_nonAnimation) {
      return true;
    } else if (closeType == CloseType.route &&
        nonAnimationType == SmartNonAnimationType.routeClose_nonAnimation) {
      return true;
    } else if (closeType == CloseType.mask &&
        nonAnimationType == SmartNonAnimationType.maskClose_nonAnimation) {
      return true;
    } else if (closeType == CloseType.back &&
        nonAnimationType == SmartNonAnimationType.maskClose_nonAnimation) {
      return true;
    }

    return false;
  }
}
