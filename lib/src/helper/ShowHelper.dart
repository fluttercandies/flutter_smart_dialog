import 'dart:async';

import '../widget/helper/smart_overlay.dart';

class ShowHelper {
  final List<Completer<void>> _showAwaitList = [];
  late SmartOverlayController smartOverlayController;

  ShowHelper(this.smartOverlayController);

  Future<void> beforeShow() async {
    var completer = Completer();
    var beforeList = List.from(_showAwaitList);
    _showAwaitList.add(completer);
    for (var completer in beforeList) {
      if (completer.isCompleted == false) {
        await completer.future;
      }
    }
    await smartOverlayController.show();
    if (completer.isCompleted == false) {
      completer.complete();
    }
    _recycleShowList();
  }

  Future<void> awaitShow() async {
    _recycleShowList();
    for (var completer in List.from(_showAwaitList)) {
      if (completer.isCompleted == false) {
        await completer.future;
      }
    }
    if (_showAwaitList.isEmpty) {
      return;
    }
    await awaitShow();
  }

  void _recycleShowList() {
    for (var completer in List.from(_showAwaitList)) {
      if (completer.isCompleted) {
        _showAwaitList.remove(completer);
      }
    }
  }
}
