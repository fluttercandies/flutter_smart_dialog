import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/pop_monitor/monitor_pop_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_harness.dart';

void main() {
  testWidgets('overlay dialog takes predictive back on the root page', (
    tester,
  ) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    bool? frameworkHandlesBack;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
        frameworkHandlesBack = call.arguments as bool;
      }
      return null;
    });
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(),
        builder: (context, child) => FlutterSmartDialog.init()(context, child),
      ),
    );
    expect(frameworkHandlesBack, isFalse);

    SmartDialog.show<void>(
      useAnimation: false,
      builder: (_) => const Text('root-dialog'),
    ).ignore();
    await tester.pumpAndSettle();

    // Android only forwards the gesture when Flutter has registered for it.
    expect(frameworkHandlesBack, isTrue);
    await _sendBackGesture(tester, 'startBackGesture', _swipeStart);
    await _sendBackGesture(tester, 'cancelBackGesture');
    await tester.pumpAndSettle();
    expect(find.text('root-dialog'), findsOneWidget);

    await _commitBackGesture(tester);
    expect(find.text('root-dialog'), findsNothing);
    expect(frameworkHandlesBack, isFalse);

    SmartDialog.show<void>(
      backType: SmartBackType.ignore,
      useAnimation: false,
      builder: (_) => const Text('ignored-dialog'),
    ).ignore();
    await tester.pumpAndSettle();
    expect(frameworkHandlesBack, isFalse);

    SmartDialog.show<void>(
      backType: SmartBackType.block,
      useAnimation: false,
      builder: (_) => const Text('blocking-dialog'),
    ).ignore();
    await tester.pumpAndSettle();
    expect(frameworkHandlesBack, isTrue);
    await _commitBackGesture(tester, button: true);
    expect(find.text('blocking-dialog'), findsOneWidget);
    expect(frameworkHandlesBack, isTrue);
    await dismissAndPump<void>(tester);
    expect(frameworkHandlesBack, isFalse);
    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('predictive back closes an overlay before the second page', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(
      tester,
      navigatorKey: navigatorKey,
      navigatorObservers: [FlutterSmartDialog.observer],
    );
    SmartDialog.show<void>(
      bindPage: false,
      useAnimation: false,
      builder: (_) => const Text('unbound-dialog'),
    ).ignore();
    await tester.pumpAndSettle();
    navigatorKey.currentState!
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('second-page')),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    expect(find.text('unbound-dialog'), findsOneWidget);
    await _commitBackGesture(tester);
    expect(find.text('unbound-dialog'), findsNothing);
    expect(find.text('second-page'), findsOneWidget);

    SmartDialog.show<void>(
      bindPage: false,
      backType: SmartBackType.ignore,
      useAnimation: false,
      builder: (_) => const Text('second-page-ignore'),
    ).ignore();
    await tester.pumpAndSettle();
    await _commitBackGesture(tester);
    expect(find.text('second-page'), findsNothing);
    expect(find.text('second-page-ignore'), findsOneWidget);
    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets(
    'predictive back uses the navigator exposed by a RouterDelegate',
    (tester) async {
      final delegate = _TestRouterDelegate();
      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: delegate,
          builder: FlutterSmartDialog.init(),
        ),
      );
      delegate.navigatorKey.currentState!
          .push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('router-page')),
            ),
          )
          .ignore();
      await tester.pumpAndSettle();
      SmartDialog.show<void>(
        useAnimation: false,
        builder: (_) => const Text('router-overlay'),
      ).ignore();
      await tester.pumpAndSettle();

      await _commitBackGesture(tester);
      expect(find.text('router-overlay'), findsNothing);
      expect(find.text('router-page'), findsOneWidget);
      await disposeSmartDialogApp(tester);
      delegate.dispose();
    },
  );

  testWidgets('predictive back keeps loading, notify, and dialog priority', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.show<void>(
      useAnimation: false,
      builder: (_) => const Text('priority-dialog'),
    ).ignore();
    SmartDialog.showNotify<void>(
      msg: 'priority-notify',
      notifyType: NotifyType.success,
      displayTime: null,
      useAnimation: false,
      backType: SmartBackType.normal,
    ).ignore();
    SmartDialog.showLoading<void>(
      useAnimation: false,
      builder: (_) => const Text('priority-loading'),
    ).ignore();
    await tester.pump(SmartDialog.config.loading.leastLoadingTime);

    await _commitBackGesture(tester);
    expect(find.text('priority-loading'), findsNothing);
    expect(find.text('priority-notify'), findsOneWidget);
    expect(find.text('priority-dialog'), findsOneWidget);
    await _commitBackGesture(tester);
    expect(find.text('priority-notify'), findsNothing);
    expect(find.text('priority-dialog'), findsOneWidget);
    await _commitBackGesture(tester);
    expect(find.text('priority-dialog'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('predictive back still dismisses a system dialog route', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(tester, navigatorKey: navigatorKey);
    SmartDialog.show<void>(
      useSystem: true,
      useAnimation: false,
      builder: (_) => const Text('system-dialog'),
    ).ignore();
    await tester.pumpAndSettle();
    expect(navigatorKey.currentState!.canPop(), isTrue);
    expect(find.text('system-dialog'), findsOneWidget);

    await _commitBackGesture(tester);
    expect(find.text('system-dialog'), findsNothing);
    expect(navigatorKey.currentState!.canPop(), isFalse);
    await disposeSmartDialogApp(tester);
  });

  testWidgets(
    'programmatic maybePop still navigates under an unbound overlay',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await pumpSmartDialogApp(tester, navigatorKey: navigatorKey);
      navigatorKey.currentState!
          .push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('programmatic-page')),
            ),
          )
          .ignore();
      await tester.pumpAndSettle();
      SmartDialog.show<void>(
        bindPage: false,
        useAnimation: false,
        builder: (_) => const Text('programmatic-overlay'),
      ).ignore();
      await tester.pumpAndSettle();

      expect(await navigatorKey.currentState!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('programmatic-page'), findsNothing);
      expect(find.text('programmatic-overlay'), findsOneWidget);
      await dismissAndPump<void>(tester);
      await disposeSmartDialogApp(tester);
    },
  );

  testWidgets('legacy system back keeps dismissing overlays before pages', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(tester, navigatorKey: navigatorKey);
    navigatorKey.currentState!
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('legacy-page')),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    SmartDialog.show<void>(
      useAnimation: false,
      builder: (_) => const Text('legacy-overlay'),
    ).ignore();
    await tester.pumpAndSettle();

    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.text('legacy-overlay'), findsNothing);
    expect(find.text('legacy-page'), findsOneWidget);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('a back callback can call maybePop without calling itself', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(tester, navigatorKey: navigatorKey);
    var onBackCount = 0;
    SmartDialog.show<void>(
      useAnimation: false,
      onBack: () async {
        onBackCount++;
        expect(await navigatorKey.currentState!.maybePop(), isFalse);
        return true;
      },
      builder: (_) => const Text('on-back-dialog'),
    ).ignore();
    await tester.pumpAndSettle();

    await _commitBackGesture(tester);
    expect(onBackCount, 1);
    expect(find.text('on-back-dialog'), findsOneWidget);
    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('normal back handling closes the active custom dialog', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.show<void>(
      useAnimation: false,
      backType: SmartBackType.normal,
      builder: (_) => const Text('back-normal'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('back-normal'), findsNothing);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('onBack interception leaves the dialog visible', (tester) async {
    await pumpSmartDialogApp(tester);
    var onBackCount = 0;
    SmartDialog.show<void>(
      useAnimation: false,
      backType: SmartBackType.normal,
      onBack: () {
        onBackCount++;
        return true;
      },
      builder: (_) => const Text('back-intercepted'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    expect(onBackCount, 1);
    expect(find.text('back-intercepted'), findsOneWidget);

    await dismissAndPump<void>(tester);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('block and ignore preserve their documented behavior', (
    tester,
  ) async {
    await pumpSmartDialogApp(tester);
    SmartDialog.showLoading<void>(
      useAnimation: false,
      backType: SmartBackType.block,
      builder: (_) => const Text('loading-blocked'),
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isTrue);
    expect(find.text('loading-blocked'), findsOneWidget);
    await dismissAndPump<void>(tester, status: SmartStatus.loading);

    SmartDialog.showNotify<void>(
      msg: 'notify-ignored',
      notifyType: NotifyType.success,
      displayTime: null,
      useAnimation: false,
      backType: SmartBackType.ignore,
    ).ignore();
    await tester.pump();

    expect(await MonitorPopRoute.handBackEvent(), isFalse);
    expect(find.text('notify-ignored'), findsOneWidget);
    await dismissAndPump<void>(tester, status: SmartStatus.allNotify);
    await disposeSmartDialogApp(tester);
  });

  testWidgets('boostMonitor uses PopEntry without changing back behavior', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await pumpSmartDialogApp(tester, navigatorKey: navigatorKey);

    final route = FlutterSmartDialog.boostMonitor(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('boost-page')),
      ),
    );
    navigatorKey.currentState!.push<void>(route!).ignore();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 2));

    SmartDialog.show<void>(
      useAnimation: false,
      backType: SmartBackType.normal,
      builder: (_) => const Text('boost-dialog'),
    ).ignore();
    await tester.pump();

    await navigatorKey.currentState!.maybePop<void>();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('boost-page'), findsOneWidget);
    expect(find.text('boost-dialog'), findsNothing);

    await navigatorKey.currentState!.maybePop<void>();
    await tester.pumpAndSettle();
    expect(find.text('boost-page'), findsNothing);

    await disposeSmartDialogApp(tester);
  });
}

const _buttonStart = {'progress': 0.0, 'swipeEdge': 0};

const _swipeStart = {
  ..._buttonStart,
  'touchOffset': [5.0, 300.0],
};

Future<void> _commitBackGesture(
  WidgetTester tester, {
  bool button = false,
}) async {
  await _sendBackGesture(
    tester,
    'startBackGesture',
    button ? _buttonStart : _swipeStart,
  );
  await _sendBackGesture(tester, 'commitBackGesture');
  await tester.pumpAndSettle();
}

Future<void> _sendBackGesture(
  WidgetTester tester,
  String method, [
  Object? arguments,
]) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.backGesture.name,
    SystemChannels.backGesture.codec.encodeMethodCall(
      MethodCall(method, arguments),
    ),
    (_) {},
  );
}

class _TestRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: const [MaterialPage<void>(child: Scaffold())],
    onDidRemovePage: (_) {},
  );

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
