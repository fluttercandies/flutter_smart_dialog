import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'smart_dialog/smart_dialog_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmartDialogPage(),
      builder: (BuildContext context, Widget child) {
        return Material(
          type: MaterialType.transparency,
          child: FlutterSmartDialog(child: child),
        );
      },
    );
  }
}
