import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => _show(),
            child: const Text('show'),
          ),
        ),
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }

  void _show() async {
    debugPrint("before:${DateTime.now().millisecondsSinceEpoch}");
    var result = await SmartDialog.show<bool>(
        tag: 'tag',
        backType: SmartBackType.block,
        clickMaskDismiss: false,
        builder: (_) {
          return ElevatedButton(
            onPressed: () {
              SmartDialog.dismiss(tag: 'tag', result: true);
            },
            child: const Text('关闭Dialog，显示Loading'),
          );
        },
        onDismiss: () {
          debugPrint("onDismiss:${DateTime.now().millisecondsSinceEpoch}");
          // showLoading()放在这里能正常显示
          // SmartDialog.showLoading();
        });

    debugPrint("aftermiss:${DateTime.now().millisecondsSinceEpoch}");
    if (result == true) {
      // showLoading() 放在这里需要加一点延时才能显示Loading
      // await Future.delayed(const Duration(seconds: 1));
      SmartDialog.showLoading();

      // 延时关闭Loading
      await Future.delayed(const Duration(seconds: 2));
      SmartDialog.dismiss();
    }
  }
}
