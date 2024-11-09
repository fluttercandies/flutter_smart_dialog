import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SmartDialogPage(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}

class SmartDialogPage extends StatelessWidget {
  const SmartDialogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('SmartDialog-EasyDemo')),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Wrap(spacing: 20, children: [
          //toast
          ElevatedButton(
            onPressed: () => _showToast(),
            child: const Text('showToast'),
          ),

          //loading
          ElevatedButton(
            onPressed: () => _showLoading(),
            child: const Text('showLoading'),
          ),

          //notify
          ElevatedButton(
            onPressed: () => _showNotify(),
            child: const Text('showNotify'),
          ),

          //dialog
          ElevatedButton(
            onPressed: () => _show(),
            child: const Text('show'),
          ),

          //attach
          ElevatedButton(
            onPressed: () => _showAttach(context),
            child: const Text('showAttach'),
          ),

          //attach
          ElevatedButton(
            onPressed: () => _bindPage(context),
            child: const Text('bindPage'),
          ),
        ]),
      ),
    );
  }

  void _showToast() async {
    SmartDialog.showToast('test toast ---- ${Random().nextInt(999)}');

    // for (var i = 0; i < 9; i++) {
    //   SmartDialog.showToast(
    //     'test toast ---- $i',
    //     displayType: SmartToastType.multi,
    //   );
    // }
  }

  void _show() async {
    SmartDialog.show(builder: (_) {
      return Container(
        height: 80,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Text(
          'easy custom dialog',
          style: TextStyle(color: Colors.white),
        ),
      );
    });
  }

  void _showAttach(BuildContext ctx) {
    attachDialog(BuildContext context) {
      SmartDialog.showAttach(
        targetContext: context,
        alignment: Alignment.bottomCenter,
        animationType: SmartAnimationType.scale,
        builder: (_) {
          return Container(height: 50, width: 30, color: Colors.red);
        },
      );
    }

    //target widget
    SmartDialog.show(
      useSystem: true,
      builder: (_) {
        return Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => attachDialog(context),
              child: const Text('target widget'),
            );
          }),
        );
      },
    );
  }

  void _bindPage(BuildContext ctx) {
    //target widget
    SmartDialog.show(builder: (_) {
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
            Navigator.push(ctx, MaterialPageRoute(builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("New Page"),
                ),
                body: const Center(child: Text("New Page")),
              );
            }));
          },
          child: const Text('to new page'),
        ),
      );
    });
  }

  void _showLoading() async {
    SmartDialog.showLoading(msg: "test one");
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showLoading(msg: "test two");
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.showLoading(msg: "test three");
    await Future.delayed(const Duration(seconds: 1));
    SmartDialog.dismiss();
  }

  void _showNotify() async {
    Alignment getAlignment() {
      var random = Random().nextInt(100) % 5;
      var alignment = Alignment.topCenter;
      if (random == 0) alignment = Alignment.topCenter;
      if (random == 1) alignment = Alignment.centerLeft;
      if (random == 2) alignment = Alignment.center;
      if (random == 3) alignment = Alignment.centerRight;
      if (random == 4) alignment = Alignment.bottomCenter;
      return alignment;
    }

    SmartDialog.showNotify(
      msg: '请求成功: ${Random().nextInt(999)}',
      notifyType: NotifyType.success,
      alignment: getAlignment(),
    );
  }
}
