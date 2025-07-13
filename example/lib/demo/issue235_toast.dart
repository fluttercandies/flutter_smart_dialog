import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(MaterialApp(
    navigatorObservers: [FlutterSmartDialog.observer],
    builder: FlutterSmartDialog.init(),
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Test",
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            show("toast1");
            show("toast2");
          },
          child: const Text(
            "Click",
          ),
        ),
      ),
    );
  }

  Future show(String msg) async {
    await SmartDialog.dismiss();
    await SmartDialog.showToast(
      msg,
      alignment: Alignment.center,
      displayTime: const Duration(seconds: 2),
      displayType: SmartToastType.last,
    );
  }
}
