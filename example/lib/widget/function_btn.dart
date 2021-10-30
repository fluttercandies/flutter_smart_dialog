import 'package:flutter/material.dart';

class BtnInfo {
  BtnInfo({this.title, this.tag});

  String? title;

  String? tag;
}

class FunctionBtn extends StatelessWidget {
  FunctionBtn({
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
