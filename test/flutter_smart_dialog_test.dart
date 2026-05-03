import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/base_controller.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';

void main() {
  group('BaseController.judgeDismissDialogType', () {
    final controller = _TestController();

    test('uses backClose_nonAnimation only for back dismissals', () {
      expect(
        controller.judgeDismissDialogType(
          CloseType.back,
          SmartNonAnimationType.backClose_nonAnimation,
        ),
        isTrue,
      );
      expect(
        controller.judgeDismissDialogType(
          CloseType.back,
          SmartNonAnimationType.maskClose_nonAnimation,
        ),
        isFalse,
      );
    });
  });
}

class _TestController extends BaseController {
  @override
  Future<void> dismiss({CloseType closeType = CloseType.normal}) async {}
}
