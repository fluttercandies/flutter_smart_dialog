import 'package:example/widget/dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'widget/function_btn.dart';

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
  final items = [
    BtnInfo(title: 'showToast', tag: 'showToast'),
    BtnInfo(title: 'showLoading', tag: 'showLoading'),
    BtnInfo(title: 'bottomDialog', tag: 'bottomDialog'),
    BtnInfo(title: 'topDialog', tag: 'topDialog'),
    BtnInfo(title: 'leftDialog', tag: 'leftDialog'),
    BtnInfo(title: 'rightDialog', tag: 'rightDialog'),
    BtnInfo(title: 'penetrateDialog', tag: 'penetrateDialog'),
  ];

  @override
  Widget build(BuildContext context) {
    return FunctionBtn(
      items: items,
      onItem: (String? tag) async {
        switch (tag) {
          case 'showToast':
            SmartDialog.showToast('test toast');
            break;
          case 'showLoading':
            SmartDialog.showLoading(msg: 'loading');
            await Future.delayed(Duration(seconds: 2));
            SmartDialog.dismiss();
            break;
          case 'bottomDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.bottomCenter,
              clickBgDismissTemp: true,
              onDismiss: () {
                print('==============test callback==============');
              },
              widget: CustomDialog(maxHeight: 400),
            );
            break;
          case 'topDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.topCenter,
              clickBgDismissTemp: true,
              widget: CustomDialog(maxHeight: 300),
            );
            break;
          case 'leftDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.centerLeft,
              clickBgDismissTemp: true,
              widget: CustomDialog(maxWidth: 260),
            );
            break;
          case 'rightDialog':
            var mask = Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.lightGreenAccent.withOpacity(0.4),
                  Colors.deepOrange.withOpacity(0.4),
                ]),
              ),
            );

            SmartDialog.show(
              alignmentTemp: Alignment.centerRight,
              clickBgDismissTemp: true,
              maskWidgetTemp: mask,
              animationDurationTemp: Duration(milliseconds: 500),
              widget: CustomDialog(maxWidth: 260),
            );
            break;
          case 'penetrateDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.bottomCenter,
              clickBgDismissTemp: false,
              isPenetrateTemp: true,
              widget: CustomDialog(maxHeight: 400),
            );
            break;
        }
      },
    );
  }
}
