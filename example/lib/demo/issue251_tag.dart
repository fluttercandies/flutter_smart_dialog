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
        title: const Text("Test"),
      ),
      body: Center(
        child: Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => show(ctx),
            child: const Text("Click"),
          );
        }),
      ),
    );
  }

  show(BuildContext context) {
    SmartDialog.showAttach(
      targetContext: context,
      alignment: Alignment.topCenter,
      maskColor: Colors.transparent,
      usePenetrate: true,
      keepSingle: true,
      tag: "tag2",
      animationType: SmartAnimationType.scale,
      builder: (_) {
        return Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              final checkMsg = SmartDialog.checkExist(tag: "tag2").toString();
              SmartDialog.showToast(checkMsg);
            },
            child: const Text('check tag status'),
          ),
        );
      },
    );
  }
}
