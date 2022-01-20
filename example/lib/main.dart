import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmartDialogPage(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}

class SmartDialogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('SmartDialog-EasyDemo')),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Wrap(spacing: 20, children: [
          //toast
          ElevatedButton(
            onPressed: () => _showToast(),
            child: Text('showToast'),
          ),

          //loading
          ElevatedButton(
            onPressed: () => _showLoading(),
            child: Text('showLoading'),
          ),

          //dialog
          ElevatedButton(
            onPressed: () => _show(),
            child: Text('show'),
          ),

          //attach
          ElevatedButton(
            onPressed: () => _showAttach(context),
            child: Text('showAttach'),
          ),
        ]),
      ),
    );
  }

  void _showToast() async {
    await SmartDialog.showToast('test toast', debounceTemp: true);
    print('--------------------------');
  }

  void _show() {
    SmartDialog.show(
      isLoadingTemp: false,
      widget: Container(
        height: 80,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          'easy custom dialog',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showAttach(BuildContext ctx) {
    var attachDialog = (BuildContext context) {
      SmartDialog.showAttach(
        targetContext: context,
        isPenetrateTemp: true,
        alignmentTemp: Alignment.topCenter,
        useSystem: true,
        widget: Container(width: 100, height: 100, color: Colors.red),
      );
    };

    //target widget
    SmartDialog.show(
      isLoadingTemp: false,
      useSystem: true,
      widget: Container(
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
            child: Text('target widget'),
          );
        }),
      ),
    );
  }

  void _showLoading() async {
    SmartDialog.showLoading(backDismiss: false);
    await Future.delayed(Duration(seconds: 2));
    SmartDialog.dismiss();
  }
}
