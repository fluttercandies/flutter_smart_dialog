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
    SmartDialog.showLoading<void>(msg: "test one");
    SmartDialog.dismiss<void>(status: SmartStatus.loading);
    SmartDialog.show<void>(
      clickMaskDismiss: false,
      builder: (_) {
        Widget child = Container(
          height: 80,
          width: 180,
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text(
            'test two',
            style: TextStyle(color: Colors.white),
          ),
        );
        return child;
      },
      displayTime: const Duration(milliseconds: 2000),
      keepSingle: true,
      backType: SmartBackType.block,
    );

    // SmartDialog.showLoading();
    // await Future.delayed(const Duration(seconds: 1));
    // await SmartDialog.dismiss(status: SmartStatus.loading);
    // SmartDialog.showToast('test toast');
    // SmartDialog.show(
    //   builder: (_) {
    //     return Container(
    //       color: Colors.white,
    //       padding: const EdgeInsets.all(30),
    //       child: const Text('test dialog'),
    //     );
    //   },
    // );
  }
}
