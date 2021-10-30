import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    this.maxHeight = double.infinity,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  final double maxWidth;

  final double maxHeight;

  @override
  Widget build(BuildContext context) {
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
}
