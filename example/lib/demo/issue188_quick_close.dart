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

  void _show() async{
    SmartDialog.show(
      builder: (_) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(30),
          child: const Text('quick close dialog'),
        );
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1));
    SmartDialog.dismiss();
  }
}
