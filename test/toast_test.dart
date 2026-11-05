import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/smart_dialog_test_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('back-to-back last toasts during a close keep only the newest', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    _showLastToast('last-a');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('last-a'), findsOneWidget);

    // Both replacements arrive while 'last-a' is still running its close animation.
    _showLastToast('last-b');
    _showLastToast('last-c');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(tester.takeException(), isNull);
    expect(find.text('last-a'), findsNothing);
    expect(find.text('last-b'), findsNothing);
    expect(find.text('last-c'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('last-c'), findsNothing);
    expect(SmartDialog.config.toast.isExist, isFalse);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('normal toasts display sequentially', (tester) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'normal-first',
      displayType: SmartToastType.normal,
      displayTime: const Duration(milliseconds: 100),
      animationTime: Duration.zero,
      useAnimation: false,
    ).ignore();
    SmartDialog.showToast(
      'normal-second',
      displayType: SmartToastType.normal,
      displayTime: const Duration(milliseconds: 100),
      animationTime: Duration.zero,
      useAnimation: false,
    ).ignore();
    await tester.pump();
    expect(find.text('normal-first'), findsOneWidget);
    expect(find.text('normal-second'), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(SmartDialog.config.toast.intervalTime);
    await tester.pump();
    expect(find.text('normal-second'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(SmartDialog.config.toast.intervalTime);
    await tester.pump();
    await disposeSmartDialogApp(tester);
  });

  testWidgets('last replaces the serial toast and dismisses it once', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    var oldDismissCount = 0;

    SmartDialog.showToast(
      'last-old',
      displayType: SmartToastType.normal,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
      onDismiss: () => oldDismissCount++,
    ).ignore();
    await tester.pump();
    final lastFuture = SmartDialog.showToast(
      'last-new',
      displayType: SmartToastType.last,
      displayTime: const Duration(milliseconds: 100),
      useAnimation: false,
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }

    expect(find.text('last-old'), findsNothing);
    expect(find.text('last-new'), findsOneWidget);
    expect(oldDismissCount, 1);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump();
    await lastFuture;
    await disposeSmartDialogApp(tester);
  });

  testWidgets('a replaced onlyRefresh timer cannot close a newer toast', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'stale-only-refresh',
      displayType: SmartToastType.onlyRefresh,
      displayTime: const Duration(milliseconds: 100),
      useAnimation: false,
    ).ignore();
    await tester.pump(const Duration(milliseconds: 10));
    SmartDialog.showToast(
      'newer-last-toast',
      displayType: SmartToastType.last,
      displayTime: const Duration(milliseconds: 300),
      useAnimation: false,
    ).ignore();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('stale-only-refresh'), findsNothing);
    expect(find.text('newer-last-toast'), findsOneWidget);

    await dismissAndPump<void>(tester, status: SmartStatus.allToast);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('onlyRefresh keeps refreshing after a mask dismissal', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    void showToast(String message) {
      SmartDialog.showToast(
        message,
        clickMaskDismiss: true,
        usePenetrate: false,
        useAnimation: false,
        displayTime: const Duration(seconds: 1),
        displayType: SmartToastType.onlyRefresh,
      ).ignore();
    }

    showToast('before-dismiss');
    await tester.pump();
    showToast('before-dismiss-refresh');
    await tester.pump();
    expect(find.text('before-dismiss-refresh'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    showToast('after-dismiss');
    await tester.pump();
    showToast('after-dismiss-refresh');
    await tester.pump();

    expect(find.text('after-dismiss-refresh'), findsOneWidget);
    expect(find.text('after-dismiss'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    await disposeSmartDialogApp(tester);
  });

  testWidgets('multi toasts can be visible at the same time', (tester) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'multi-first',
      displayType: SmartToastType.multi,
      displayTime: const Duration(milliseconds: 100),
      useAnimation: false,
    ).ignore();
    SmartDialog.showToast(
      'multi-second',
      displayType: SmartToastType.multi,
      displayTime: const Duration(milliseconds: 150),
      useAnimation: false,
    ).ignore();
    await tester.pump();

    expect(find.text('multi-first'), findsOneWidget);
    expect(find.text('multi-second'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('multi-first'), findsNothing);
    expect(find.text('multi-second'), findsNothing);
    expect(
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.toast}),
      isFalse,
    );
    await disposeSmartDialogApp(tester);
  });

  testWidgets('allToast closes serial and multi toasts exactly once', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    var serialDismissCount = 0;
    var queuedDismissCount = 0;
    var multiDismissCount = 0;

    SmartDialog.showToast(
      'all-serial',
      displayType: SmartToastType.normal,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
      onDismiss: () => serialDismissCount++,
    ).ignore();
    SmartDialog.showToast(
      'all-queued',
      displayType: SmartToastType.normal,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
      onDismiss: () => queuedDismissCount++,
    ).ignore();
    SmartDialog.showToast(
      'all-multi',
      displayType: SmartToastType.multi,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
      onDismiss: () => multiDismissCount++,
    ).ignore();
    await tester.pump();

    await dismissAndPump<void>(tester, status: SmartStatus.allToast);
    expect(find.text('all-serial'), findsNothing);
    expect(find.text('all-queued'), findsNothing);
    expect(find.text('all-multi'), findsNothing);
    expect(serialDismissCount, 1);
    expect(queuedDismissCount, 0);
    expect(multiDismissCount, 1);
    expect(
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.toast}),
      isFalse,
    );
    await disposeSmartDialogApp(tester);
  });

  testWidgets('single toast dismissal prioritizes serial over multi', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);

    SmartDialog.showToast(
      'priority-multi',
      displayType: SmartToastType.multi,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
    ).ignore();
    SmartDialog.showToast(
      'priority-serial',
      displayType: SmartToastType.normal,
      displayTime: const Duration(seconds: 1),
      useAnimation: false,
    ).ignore();
    await tester.pump();

    await dismissAndPump<void>(tester, status: SmartStatus.toast);
    expect(find.text('priority-serial'), findsNothing);
    expect(find.text('priority-multi'), findsOneWidget);

    await dismissAndPump<void>(tester, status: SmartStatus.toast);
    expect(find.text('priority-multi'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('works in a standalone Cupertino UI tree without a bridge', (
    tester,
  ) async {
    SmartDialogTestState.reset();
    await tester.pumpWidget(
      cupertino.CupertinoApp(
        home: const cupertino.CupertinoPageScaffold(child: SizedBox.expand()),
        builder: FlutterSmartDialog.init(),
      ),
    );
    await tester.pump();

    SmartDialog.showToast(
      'standalone-cupertino-ui',
      useAnimation: false,
      displayTime: const Duration(milliseconds: 100),
    ).ignore();
    await tester.pump();
    expect(find.text('standalone-cupertino-ui'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await disposeSmartDialogApp(tester);
  });
}

void _showLastToast(String msg) {
  SmartDialog.showToast(
    msg,
    displayType: SmartToastType.last,
    displayTime: const Duration(seconds: 1),
    animationTime: const Duration(milliseconds: 100),
  ).ignore();
}
