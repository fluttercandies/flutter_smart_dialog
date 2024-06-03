import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: Scaffold(
        body: Center(
          child: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (context) => const TestPage()),
                );
              },
              child: const Text('jump page'),
            );
          }),
        ),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
    SmartDialog.showLoading();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(body: Center(child: Text('test page'))),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}
