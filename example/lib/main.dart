import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmartDialogPage(),
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
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
    return FunctionItems(
      items: items,
      onItem: (String? tag) async {
        switch (tag) {
          case 'showToast':
            SmartDialog.showToast('test toast');
            break;
          case 'showLoading':
            SmartDialog.showLoading();
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
              widget: contentWidget(maxHeight: 400),
            );
            break;
          case 'topDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.topCenter,
              clickBgDismissTemp: true,
              widget: contentWidget(maxHeight: 300),
            );
            break;
          case 'leftDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.centerLeft,
              clickBgDismissTemp: true,
              widget: contentWidget(maxWidth: 260),
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
              widget: contentWidget(maxWidth: 260),
            );
            break;
          case 'penetrateDialog':
            SmartDialog.show(
              alignmentTemp: Alignment.bottomCenter,
              clickBgDismissTemp: false,
              isPenetrateTemp: true,
              widget: contentWidget(maxHeight: 400),
            );
            break;
        }
      },
    );
  }
}

Widget contentWidget({
  double maxWidth = double.infinity,
  double maxHeight = double.infinity,
}) {
  return Container(
    constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
      ],
    ),
    child: ListView.builder(
      itemCount: 30,
      itemBuilder: (BuildContext context, int index) {
        return Column(children: [
          ListTile(
            leading: Icon(Icons.bubble_chart),
            title: Text('title---------------$index'),
          ),

          //line
          Container(height: 1, color: Colors.black.withOpacity(0.1)),
        ]);
      },
    ),
  );
}

class BtnInfo {
  BtnInfo({this.title, this.tag});

  String? title;

  String? tag;
}

class FunctionItems extends StatelessWidget {
  FunctionItems({
    required this.items,
    required this.onItem,
  });

  final List<BtnInfo> items;

  final Function(String? data) onItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('SmartDialog')),
      body: Container(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Material(
            color: Colors.white,
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: items.map((e) {
                return Container(
                  padding: EdgeInsets.all(15),
                  child: RawMaterialButton(
                    fillColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 100, minHeight: 36.0),
                    elevation: 5,
                    onPressed: () => onItem.call(e.tag),
                    child: Container(
                      width: 130,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      child: Text('${e.title}'),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
